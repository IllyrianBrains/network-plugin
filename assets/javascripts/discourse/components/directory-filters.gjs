import { fn } from "@ember/helper";
import { on } from "@ember/modifier";
import { eq } from "discourse/truth-helpers";
import DButton from "discourse/ui-kit/d-button";
import dIcon from "discourse/ui-kit/helpers/d-icon";
import { MENTORING_OPTIONS } from "discourse/plugins/discourse-professional-network/discourse/lib/mentoring";
import {
  AVAILABILITY_OPTIONS,
  BUSINESS_OPTIONS,
  EXPERIENCE_LEVEL_OPTIONS,
} from "discourse/plugins/discourse-professional-network/discourse/lib/options";

const ProfessionalNetworkDirectoryFilters = <template>
  <form {{on "submit" @directory.submit}}>
    <div class="professional-network-field is-wide">
      <label for="professional-network-directory-q">Search</label>
      <div class="professional-network-search-input">
        {{dIcon "magnifying-glass"}}
        <input
          id="professional-network-directory-q"
          placeholder="Name, headline, company, skills…"
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
      {{#if @directory.canShowAllAccounts}}
        <label class="professional-network-chip">
          <input
            checked={{@directory.filters.include_unpublished}}
            type="checkbox"
            {{on
              "change"
              (fn @directory.changeFilterCheckbox "include_unpublished")
            }}
          />Show all network accounts</label>
      {{/if}}
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
          <label for="professional-network-directory-city">City</label>
          <input
            id="professional-network-directory-city"
            type="text"
            value={{@directory.filters.city}}
            {{on "input" (fn @directory.changeFilter "city")}}
          />
        </div>
        <div class="professional-network-field">
          <label for="professional-network-directory-country">Country</label>
          <input
            id="professional-network-directory-country"
            type="text"
            value={{@directory.filters.country}}
            {{on "input" (fn @directory.changeFilter "country")}}
          />
        </div>
        <div class="professional-network-field">
          <label for="professional-network-directory-field">Field of expertise</label>
          <input
            id="professional-network-directory-field"
            type="text"
            value={{@directory.filters.field}}
            {{on "input" (fn @directory.changeFilter "field")}}
          />
        </div>
        <div class="professional-network-field">
          <label for="professional-network-directory-skill">Skill</label>
          <input
            id="professional-network-directory-skill"
            type="text"
            value={{@directory.filters.skill}}
            {{on "input" (fn @directory.changeFilter "skill")}}
          />
        </div>
        <div class="professional-network-field">
          <label for="professional-network-directory-experience">Experience
            level</label>
          <select
            id="professional-network-directory-experience"
            {{on
              "change"
              (fn @directory.changeFilterAndSearch "experience_level")
            }}
          >
            <option
              selected={{eq @directory.filters.experience_level ""}}
              value=""
            >Any</option>
            {{#each EXPERIENCE_LEVEL_OPTIONS as |choice|}}
              <option
                selected={{eq @directory.filters.experience_level choice.value}}
                value={{choice.value}}
              >{{choice.label}}</option>
            {{/each}}
          </select>
        </div>
        <div class="professional-network-field">
          <label
            for="professional-network-directory-availability"
          >Availability</label>
          <select
            id="professional-network-directory-availability"
            {{on "change" (fn @directory.changeFilterAndSearch "availability")}}
          >
            <option
              selected={{eq @directory.filters.availability ""}}
              value=""
            >Any</option>
            {{#each AVAILABILITY_OPTIONS as |choice|}}
              <option
                selected={{eq @directory.filters.availability choice.value}}
                value={{choice.value}}
              >{{choice.label}}</option>
            {{/each}}
          </select>
        </div>
        <div class="professional-network-field">
          <label for="professional-network-directory-aspiration-field">Career
            aspiration field</label>
          <input
            id="professional-network-directory-aspiration-field"
            type="text"
            value={{@directory.filters.aspiration_field}}
            {{on "input" (fn @directory.changeFilter "aspiration_field")}}
          />
        </div>
        <div class="professional-network-field">
          <label for="professional-network-directory-aspiration-subfield">Career
            aspiration subfield</label>
          <input
            id="professional-network-directory-aspiration-subfield"
            type="text"
            value={{@directory.filters.aspiration_subfield}}
            {{on "input" (fn @directory.changeFilter "aspiration_subfield")}}
          />
        </div>
        <div class="professional-network-field">
          <label for="professional-network-directory-mentoring">Mentoring
            interest</label>
          <select
            id="professional-network-directory-mentoring"
            {{on
              "change"
              (fn @directory.changeFilterAndSearch "mentoring_interest")
            }}
          >
            <option
              selected={{eq @directory.filters.mentoring_interest ""}}
              value=""
            >Any</option>
            {{#each MENTORING_OPTIONS as |choice|}}
              <option
                selected={{eq
                  @directory.filters.mentoring_interest
                  choice.value
                }}
                value={{choice.value}}
              >{{choice.label}}</option>
            {{/each}}
          </select>
        </div>
        <div class="professional-network-field">
          <label for="professional-network-directory-business">Looking for</label>
          <select
            id="professional-network-directory-business"
            {{on
              "change"
              (fn @directory.changeFilterAndSearch "business_interest")
            }}
          >
            <option
              selected={{eq @directory.filters.business_interest ""}}
              value=""
            >Any</option>
            {{#each BUSINESS_OPTIONS as |choice|}}
              <option
                selected={{eq
                  @directory.filters.business_interest
                  choice.value
                }}
                value={{choice.value}}
              >{{choice.label}}</option>
            {{/each}}
          </select>
        </div>
        <div class="professional-network-field is-wide">
          <div class="professional-network-chips">
            <label class="professional-network-chip">
              <input
                checked={{@directory.filters.open_to_consulting}}
                type="checkbox"
                {{on
                  "change"
                  (fn @directory.changeFilterCheckbox "open_to_consulting")
                }}
              />Open to consulting
            </label>
            <label class="professional-network-chip">
              <input
                checked={{@directory.filters.offering_services}}
                type="checkbox"
                {{on
                  "change"
                  (fn @directory.changeFilterCheckbox "offering_services")
                }}
              />Offering services
            </label>
          </div>
        </div>
      </div>
    </details>
  </form>
</template>;

export default ProfessionalNetworkDirectoryFilters;
