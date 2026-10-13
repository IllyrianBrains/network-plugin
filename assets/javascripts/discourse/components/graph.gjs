import { tracked } from "@glimmer/tracking";
import { on } from "@ember/modifier";
import { action } from "@ember/object";
import { eq } from "discourse/truth-helpers";
import dIcon from "discourse/ui-kit/helpers/d-icon";
import ProfessionalNetworkGraphFilters from "discourse/plugins/discourse-professional-network/discourse/components/graph-filters";
import ProfessionalNetworkGraphLegend from "discourse/plugins/discourse-professional-network/discourse/components/graph-legend";
import ProfessionalNetworkGraphNarrowPrompt from "discourse/plugins/discourse-professional-network/discourse/components/graph-narrow-prompt";
import ProfessionalNetworkGraphPopup from "discourse/plugins/discourse-professional-network/discourse/components/graph-popup";
import ProfessionalNetworkGraphTools from "discourse/plugins/discourse-professional-network/discourse/components/graph-tools";
import ProfessionalNetworkMap from "discourse/plugins/discourse-professional-network/discourse/components/map";
import ProfessionalNetworkGraphState from "discourse/plugins/discourse-professional-network/discourse/lib/graph-state";

export default class ProfessionalNetworkGraph extends ProfessionalNetworkGraphState {
  @tracked viewMode = "graph";

  @action
  showGraph() {
    this.viewMode = "graph";
  }

  @action
  showMap() {
    this.viewMode = "map";
  }

  <template>
    <div class="professional-network-graph" {{this.load}}>
      <header>
        <p class="professional-network-panel__eyebrow">Professional network</p>
        <h2>Network</h2>
        <p>Discover how members and organizations are connected by shared cities
          and areas of expertise.</p>
      </header>

      <div
        aria-label="Network view"
        class="professional-network-graph__view-switch"
        role="group"
      >
        <button
          aria-pressed={{eq this.viewMode "graph"}}
          class={{if (eq this.viewMode "graph") "active" ""}}
          type="button"
          {{on "click" this.showGraph}}
        >Graph</button>
        <button
          aria-pressed={{eq this.viewMode "map"}}
          class={{if (eq this.viewMode "map") "active" ""}}
          type="button"
          {{on "click" this.showMap}}
        >Map</button>
      </div>

      {{#if (eq this.viewMode "map")}}
        <ProfessionalNetworkMap />
      {{else if this.loading}}
        <div class="professional-network-graph__placeholder">
          {{dIcon "spinner" class="fa-spin"}}
          <p>Loading network…</p>
        </div>
      {{else if this.errored}}
        <div
          class="professional-network-graph__placeholder professional-network-graph__placeholder--error"
        >
          {{dIcon "triangle-exclamation"}}
          <p>Could not load the member network.</p>
        </div>
      {{else if (eq this.nodeCount 0)}}
        <div class="professional-network-graph__placeholder">
          {{dIcon "circle-info"}}
          <p>No public profile data yet.</p>
        </div>
      {{else if this.readyToRender}}
        <div class="professional-network-graph__toolbar">
          <ProfessionalNetworkGraphLegend />
          <div class="professional-network-graph__toolbar-controls">
            <ProfessionalNetworkGraphFilters @graph={{this}} />
            <ProfessionalNetworkGraphTools @graph={{this}} />
          </div>
        </div>
        <div class="professional-network-graph__canvas-wrap">
          <div class="professional-network-graph__canvas" {{this.setup}}></div>
          <ProfessionalNetworkGraphPopup
            @onClose={{this.closePopup}}
            @popup={{this.popup}}
          />
        </div>
        <p class="professional-network-graph__status">
          {{#if this.hasActiveFilters}}
            Showing
            {{this.visibleParticipantCount}}
            of
            {{this.participantCount}}
            members and organizations matching your filters.
          {{else}}
            {{this.memberCount}}
            members,
            {{this.organizationCount}}
            organizations,
            {{this.edgeCount}}
            connections. Bigger cities and fields have more members.
          {{/if}}
          Tap a node for details, or double-tap a member or organization to open
          their profile.
        </p>
      {{else}}
        <ProfessionalNetworkGraphNarrowPrompt @graph={{this}} />
      {{/if}}
    </div>
  </template>
}
