import Component from "@glimmer/component";
import { tracked } from "@glimmer/tracking";
import { action } from "@ember/object";
import { modifier } from "ember-modifier";
import { ajax } from "discourse/lib/ajax";
import DiscourseURL, { userPath } from "discourse/lib/url";
import {
  buildCytoscapeElements,
  buildCytoscapeStyle,
  GRAPH_LAYOUT,
} from "discourse/plugins/discourse-professional-network/discourse/lib/graph-cytoscape";
import { applyGraphFilters } from "discourse/plugins/discourse-professional-network/discourse/lib/graph-filtering";
import {
  KIND_LABELS,
  LARGE_NETWORK_THRESHOLD,
  QUICK_FILTER_LIMIT,
  topLabelsByCount,
  uniqueSortedLabels,
} from "discourse/plugins/discourse-professional-network/discourse/lib/graph-options";
import loadCytoscape from "discourse/plugins/discourse-professional-network/discourse/lib/load-cytoscape";

export default class ProfessionalNetworkGraphState extends Component {
  @tracked loading = true;
  @tracked errored = false;
  @tracked nodeCount = 0;
  @tracked edgeCount = 0;
  @tracked memberCount = 0;
  @tracked organizationCount = 0;
  @tracked visibleParticipantCount = 0;
  @tracked search = "";
  @tracked cityFilter = "";
  @tracked fieldFilter = "";
  @tracked cityOptions = [];
  @tracked fieldOptions = [];
  @tracked quickCities = [];
  @tracked quickFields = [];
  @tracked showFullNetwork = false;
  @tracked popup = null;
  cy = null;
  popupNode = null;
  nodes = [];
  edges = [];

  load = modifier(() => {
    this.loadData();
  });

  setup = modifier((element) => {
    this.buildGraph(element);
    return () => this.cy?.destroy();
  });

  get hasActiveFilters() {
    return Boolean(this.search || this.cityFilter || this.fieldFilter);
  }

  get participantCount() {
    return this.memberCount + this.organizationCount;
  }

  get isLargeNetwork() {
    return this.participantCount > LARGE_NETWORK_THRESHOLD;
  }

  // Render the full graph straight away for small networks; for large ones, wait
  // until the viewer picks a filter (or opts in) so the first paint is readable.
  get readyToRender() {
    return (
      !this.isLargeNetwork || this.showFullNetwork || this.hasActiveFilters
    );
  }

  async loadData() {
    try {
      await loadCytoscape();
      const response = await ajax("/network/network-graph");
      this.nodes = response.nodes || [];
      this.edges = response.edges || [];
      this.nodeCount = this.nodes.length;
      this.edgeCount = this.edges.length;
      this.memberCount = this.nodes.filter(
        (node) => node.type === "member"
      ).length;
      this.organizationCount = this.nodes.filter(
        (node) => node.type === "organization"
      ).length;
      this.visibleParticipantCount = this.participantCount;
      this.cityOptions = uniqueSortedLabels(this.nodes, "city");
      this.fieldOptions = uniqueSortedLabels(this.nodes, "field");
      this.quickCities = topLabelsByCount(
        this.nodes,
        "city",
        QUICK_FILTER_LIMIT
      );
      this.quickFields = topLabelsByCount(
        this.nodes,
        "field",
        QUICK_FILTER_LIMIT
      );
    } catch {
      this.errored = true;
    } finally {
      this.loading = false;
    }
  }

  buildGraph(element) {
    /* global cytoscape */
    this.cy = cytoscape({
      container: element,
      elements: buildCytoscapeElements(this.nodes, this.edges),
      style: buildCytoscapeStyle(this.nodes),
      layout: GRAPH_LAYOUT,
      wheelSensitivity: 0.2,
    });

    this.cy.on("tap", "node", (event) => {
      const node = event.target;
      const neighborhood = node.closedNeighborhood();
      this.cy.elements().removeClass("pn-faded");
      this.cy.elements().not(neighborhood).addClass("pn-faded");
      this.openPopup(node);
    });
    this.cy.on("tap", (event) => {
      if (event.target === this.cy) {
        this.cy.elements().removeClass("pn-faded");
        this.closePopup();
      }
    });
    this.cy.on("pan zoom position", () => {
      if (this.popupNode) {
        this.positionPopup(this.popupNode);
      }
    });
    this.cy.on("dbltap", "node[username]", (event) => {
      const username = event.target.data("username");
      if (username) {
        DiscourseURL.routeTo(
          userPath(`${encodeURIComponent(username)}/professional-profile`)
        );
      }
    });

    // A filter picked before the graph existed (a quick-select chip on the
    // narrow-network prompt) is applied now that there's a `cy` to apply it to.
    this.applyFilters();
  }

  openPopup(node) {
    const type = node.data("type");
    const degree = node.degree();
    const connectionLabel = `${degree} connection${degree === 1 ? "" : "s"}`;
    let meta;
    let username = null;

    if (type === "member" || type === "organization") {
      const neighbors = node.connectedEdges().connectedNodes().not(node);
      const city = neighbors
        .filter("[type = 'city']")
        .map((neighbor) => neighbor.data("label"))[0];
      const fields = neighbors
        .filter("[type = 'field']")
        .map((neighbor) => neighbor.data("label"));
      const fieldsLabel =
        type === "organization" ? "Sector" : "Fields of expertise";
      meta = [
        city ? `City: ${city}` : null,
        fields.length ? `${fieldsLabel}: ${fields.join(", ")}` : null,
        connectionLabel,
      ].filter(Boolean);
      username = node.data("username");
    } else {
      meta = [connectionLabel];
    }

    this.popupNode = node;
    this.popup = {
      kindLabel: KIND_LABELS[type] || type,
      title: node.data("label"),
      meta,
      profileUrl: username
        ? userPath(`${encodeURIComponent(username)}/professional-profile`)
        : null,
      left: 0,
      top: 0,
    };
    this.positionPopup(node);
  }

  positionPopup(node) {
    if (!this.popup) {
      return;
    }
    const position = node.renderedPosition();
    this.popup = { ...this.popup, left: position.x, top: position.y };
  }

  @action
  closePopup() {
    this.popupNode = null;
    this.popup = null;
  }

  applyFilters() {
    if (!this.cy) {
      return;
    }

    this.visibleParticipantCount = applyGraphFilters(this.cy, {
      search: this.search,
      cityFilter: this.cityFilter,
      fieldFilter: this.fieldFilter,
    });

    if (this.popupNode?.hasClass("pn-filtered")) {
      this.closePopup();
    }

    const visible = this.cy.elements().not(".pn-filtered");
    if (visible.length) {
      this.cy.fit(visible, 30);
    }
  }

  setCityFilter(value) {
    this.cityFilter = value;
    this.applyFilters();
  }

  setFieldFilter(value) {
    this.fieldFilter = value;
    this.applyFilters();
  }

  @action
  updateSearch(event) {
    this.search = event.target.value;
    this.applyFilters();
  }

  @action
  updateCityFilter(event) {
    this.setCityFilter(event.target.value);
  }

  @action
  updateFieldFilter(event) {
    this.setFieldFilter(event.target.value);
  }

  @action
  quickSelectCity(city) {
    this.setCityFilter(city);
  }

  @action
  quickSelectField(field) {
    this.setFieldFilter(field);
  }

  @action
  resetFilters() {
    this.search = "";
    this.cityFilter = "";
    this.fieldFilter = "";
    this.applyFilters();
  }

  @action
  showAnyway() {
    this.showFullNetwork = true;
  }

  @action
  zoomIn() {
    this.cy?.zoom({
      level: this.cy.zoom() * 1.25,
      renderedPosition: { x: this.cy.width() / 2, y: this.cy.height() / 2 },
    });
  }

  @action
  zoomOut() {
    this.cy?.zoom({
      level: this.cy.zoom() / 1.25,
      renderedPosition: { x: this.cy.width() / 2, y: this.cy.height() / 2 },
    });
  }

  @action
  fitView() {
    if (!this.cy) {
      return;
    }
    const visible = this.cy.elements().not(".pn-filtered");
    this.cy.fit(visible.length ? visible : this.cy.elements(), 30);
  }
}
