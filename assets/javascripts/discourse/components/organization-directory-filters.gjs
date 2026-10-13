import { fn } from "@ember/helper";
import { on } from "@ember/modifier";
import { eq } from "discourse/truth-helpers";
import DButton from "discourse/ui-kit/d-button";
import dIcon from "discourse/ui-kit/helpers/d-icon";
import { ORGANIZATION_TYPE_OPTIONS } from "discourse/plugins/discourse-professional-network/discourse/lib/options";

const OrganizationDirectoryFilters = <template>
  <form {{on "submit" @directory.submit}}>
    <div class="professional-network-field is-wide">
      <label for="professional-network-organization-directory-q">Search
        organizations</label>
      <div class="professional-network-search-input">
        {{dIcon "magnifying-glass"}}
        <input
          id="professional-network-organization-directory-q"
          placeholder="Name, mission, sector, projects, needs…"
          type="text"
          value={{@directory.filters.q}}
          {{on "input" (fn @directory.changeFilter "q")}}
        />
      </div>
    </div>
    <div class="professional-network-directory__actions">
      <DButton
        class="btn-primary"
        @disabled={{@directory.loading}}
        @translatedLabel={{if @directory.loading "Searching…" "Search"}}
        @type="submit"
      />
      <DButton
        class="btn-flat"
        @action={{@directory.reset}}
        @translatedLabel="Clear filters"
      />
    </div>
    {{#if @directory.activeFilters.length}}
      <div class="professional-network-chips">
        {{#each @directory.activeFilters as |chip|}}
          <DButton
            class="professional-network-chip professional-network-chip--removable"
            @action={{fn @directory.removeFilter chip.key}}
            @icon="xmark"
            @translatedLabel={{chip.display}}
            @translatedTitle="Remove this filter"
          />
        {{/each}}
      </div>
    {{/if}}
    <details class="professional-network-form-section">
      <summary>
        {{dIcon "sliders"}}
        <span>Filters</span>
        {{#if @directory.activeFilters.length}}<small
          >{{@directory.activeFilters.length}} active</small>{{/if}}
      </summary>
      <div class="professional-network-form-section__body">
        <div class="professional-network-field">
          <label
            for="professional-network-organization-directory-type"
          >Organization type</label>
          <select
            id="professional-network-organization-directory-type"
            {{on
              "change"
              (fn @directory.changeFilterAndSearch "organization_type")
            }}
          >
            <option
              selected={{eq @directory.filters.organization_type ""}}
              value=""
            >Any</option>
            {{#each ORGANIZATION_TYPE_OPTIONS as |choice|}}
              <option
                selected={{eq
                  @directory.filters.organization_type
                  choice.value
                }}
                value={{choice.value}}
              >{{choice.label}}</option>
            {{/each}}
          </select>
        </div>
        <div class="professional-network-field">
          <label
            for="professional-network-organization-directory-sector"
          >Sector</label>
          <input
            id="professional-network-organization-directory-sector"
            type="text"
            value={{@directory.filters.sector}}
            {{on "input" (fn @directory.changeFilter "sector")}}
          />
        </div>
        <div class="professional-network-field">
          <label
            for="professional-network-organization-directory-stage"
          >Stage</label>
          <input
            id="professional-network-organization-directory-stage"
            type="text"
            value={{@directory.filters.stage}}
            {{on "input" (fn @directory.changeFilter "stage")}}
          />
        </div>
        <div class="professional-network-field">
          <label
            for="professional-network-organization-directory-city"
          >City</label>
          <input
            id="professional-network-organization-directory-city"
            type="text"
            value={{@directory.filters.city}}
            {{on "input" (fn @directory.changeFilter "city")}}
          />
        </div>
        <div class="professional-network-field">
          <label
            for="professional-network-organization-directory-country"
          >Country</label>
          <input
            id="professional-network-organization-directory-country"
            type="text"
            value={{@directory.filters.country}}
            {{on "input" (fn @directory.changeFilter "country")}}
          />
        </div>
        <div class="professional-network-field">
          <label
            for="professional-network-organization-directory-collaboration"
          >Collaboration interest</label>
          <input
            id="professional-network-organization-directory-collaboration"
            placeholder="Mentoring, sponsorship, research…"
            type="text"
            value={{@directory.filters.collaboration_interest}}
            {{on "input" (fn @directory.changeFilter "collaboration_interest")}}
          />
        </div>
        <div class="professional-network-field is-wide">
          <div class="professional-network-chips">
            <label class="professional-network-chip">
              <input
                checked={{@directory.filters.offers_mentoring}}
                type="checkbox"
                {{on
                  "change"
                  (fn @directory.changeFilterCheckbox "offers_mentoring")
                }}
              />Offers mentoring
            </label>
          </div>
        </div>
      </div>
    </details>
  </form>
</template>;

export default OrganizationDirectoryFilters;
