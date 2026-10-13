import { fn } from "@ember/helper";
import DButton from "discourse/ui-kit/d-button";
import ProfessionalNetworkGraphFilters from "discourse/plugins/discourse-professional-network/discourse/components/graph-filters";

const ProfessionalNetworkGraphNarrowPrompt = <template>
  <div class="professional-network-graph__prompt">
    <p>This network has
      {{@graph.memberCount}}
      members and
      {{@graph.organizationCount}}
      organizations — pick a city, a field, or search for someone to keep the
      map readable.</p>
    {{#if @graph.quickCities.length}}
      <div class="professional-network-chips">
        <span class="professional-network-graph__chips-label">Popular cities:</span>
        {{#each @graph.quickCities as |city|}}
          <DButton
            class="professional-network-chip"
            @action={{fn @graph.quickSelectCity city}}
            @translatedLabel={{city}}
          />
        {{/each}}
      </div>
    {{/if}}
    {{#if @graph.quickFields.length}}
      <div class="professional-network-chips">
        <span class="professional-network-graph__chips-label">Popular fields:</span>
        {{#each @graph.quickFields as |field|}}
          <DButton
            class="professional-network-chip"
            @action={{fn @graph.quickSelectField field}}
            @translatedLabel={{field}}
          />
        {{/each}}
      </div>
    {{/if}}
    <ProfessionalNetworkGraphFilters @graph={{@graph}} />
    <DButton
      class="btn-flat professional-network-graph__prompt-show-all"
      @action={{@graph.showAnyway}}
      @translatedLabel="Show full network anyway"
    />
  </div>
</template>;

export default ProfessionalNetworkGraphNarrowPrompt;
