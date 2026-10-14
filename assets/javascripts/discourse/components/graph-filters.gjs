import { on } from "@ember/modifier";
import { eq } from "discourse/truth-helpers";
import dIcon from "discourse/ui-kit/helpers/d-icon";

const ProfessionalNetworkGraphFilters = <template>
  <div class="professional-network-graph__filters">
    <div class="professional-network-field">
      <label for="professional-network-graph-search">Search</label>
      <div class="professional-network-search-input">
        {{dIcon "magnifying-glass"}}
        <input
          id="professional-network-graph-search"
          placeholder="Search members…"
          type="text"
          value={{@graph.search}}
          {{on "input" @graph.updateSearch}}
        />
      </div>
    </div>
    <div class="professional-network-field">
      <label for="professional-network-graph-city">City</label>
      <select
        id="professional-network-graph-city"
        {{on "change" @graph.updateCityFilter}}
      >
        <option selected={{eq @graph.cityFilter ""}} value="">All cities</option>
        {{#each @graph.cityOptions as |city|}}
          <option
            selected={{eq @graph.cityFilter city}}
            value={{city}}
          >{{city}}</option>
        {{/each}}
      </select>
    </div>
    <div class="professional-network-field">
      <label for="professional-network-graph-expertise">Field of expertise</label>
      <select
        id="professional-network-graph-expertise"
        {{on "change" @graph.updateFieldFilter}}
      >
        <option selected={{eq @graph.fieldFilter ""}} value="">All fields</option>
        {{#each @graph.fieldOptions as |field|}}
          <option
            selected={{eq @graph.fieldFilter field}}
            value={{field}}
          >{{field}}</option>
        {{/each}}
      </select>
    </div>
    <div class="professional-network-field">
      <label for="professional-network-graph-group">Group</label>
      <select
        id="professional-network-graph-group"
        {{on "change" @graph.updateGroupFilter}}
      >
        <option selected={{eq @graph.groupFilter ""}} value="">All groups</option>
        {{#each @graph.groupOptions as |group|}}
          <option
            selected={{eq @graph.groupFilter group}}
            value={{group}}
          >{{group}}</option>
        {{/each}}
      </select>
    </div>
  </div>
</template>;

export default ProfessionalNetworkGraphFilters;
