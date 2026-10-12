import Component from "@glimmer/component";
import { tracked } from "@glimmer/tracking";
import { modifier } from "ember-modifier";
import { ajax } from "discourse/lib/ajax";
import { eq } from "discourse/truth-helpers";
import loadCytoscape from "discourse/plugins/discourse-professional-network/discourse/lib/load-cytoscape";

const COLORS = { member: "#2b6cb0", city: "#2f855a", field: "#c05621" };

export default class ProfessionalNetworkGraph extends Component {
  @tracked loading = true;
  @tracked errored = false;
  @tracked nodeCount = 0;
  @tracked edgeCount = 0;
  cy = null;

  setup = modifier((element) => {
    this.renderGraph(element);
    return () => this.cy?.destroy();
  });

  async renderGraph(element) {
    try {
      await loadCytoscape();
      const response = await ajax("/professional-network/network-graph");
      const nodes = response.nodes || [];
      const edges = response.edges || [];
      this.nodeCount = nodes.length;
      this.edgeCount = edges.length;

      /* global cytoscape */
      this.cy = cytoscape({
        container: element,
        elements: [
          ...nodes.map((node) => ({
            data: { id: node.id, label: node.label, type: node.type },
          })),
          ...edges.map((edge) => ({
            data: { source: edge.source, target: edge.target },
          })),
        ],
        style: [
          {
            selector: "node",
            style: {
              label: "data(label)",
              "font-size": 9,
              color: "#222",
              "text-valign": "bottom",
              "text-margin-y": 4,
              "background-color": (el) => COLORS[el.data("type")] || "#888",
              width: (el) => (el.data("type") === "member" ? 16 : 22),
              height: (el) => (el.data("type") === "member" ? 16 : 22),
            },
          },
          {
            selector: "edge",
            style: {
              width: 1,
              "line-color": "#ccc",
              "curve-style": "haystack",
            },
          },
          { selector: ".pn-faded", style: { opacity: 0.15 } },
        ],
        layout: {
          name: "cose",
          animate: false,
          nodeRepulsion: 9000,
          idealEdgeLength: 70,
        },
        wheelSensitivity: 0.2,
      });

      this.cy.on("tap", "node", (event) => {
        const neighborhood = event.target.closedNeighborhood();
        this.cy.elements().removeClass("pn-faded");
        this.cy.elements().not(neighborhood).addClass("pn-faded");
      });
      this.cy.on("tap", (event) => {
        if (event.target === this.cy) {
          this.cy.elements().removeClass("pn-faded");
        }
      });
    } catch {
      this.errored = true;
    } finally {
      this.loading = false;
    }
  }

  <template>
    <div class="professional-network-graph">
      <div class="professional-network-graph__legend">
        <span><span
            class="professional-network-graph__dot professional-network-graph__dot--member"
          ></span>Member</span>
        <span><span
            class="professional-network-graph__dot professional-network-graph__dot--city"
          ></span>City</span>
        <span><span
            class="professional-network-graph__dot professional-network-graph__dot--field"
          ></span>Field of expertise</span>
      </div>
      {{#if this.loading}}
        <p class="professional-network-graph__status">Loading network…</p>
      {{else if this.errored}}
        <p
          class="professional-network-graph__status professional-network-error"
        >Could not load the member network.</p>
      {{else if (eq this.nodeCount 0)}}
        <p class="professional-network-graph__status">No public profile data
          yet.</p>
      {{else}}
        <p class="professional-network-graph__status">{{this.nodeCount}}
          nodes,
          {{this.edgeCount}}
          edges. Tap a node to highlight its connections.</p>
      {{/if}}
      <div class="professional-network-graph__canvas" {{this.setup}}></div>
    </div>
  </template>
}
