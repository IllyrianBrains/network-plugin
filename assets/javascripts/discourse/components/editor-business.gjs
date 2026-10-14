import { fn } from "@ember/helper";
import { on } from "@ember/modifier";
import { includes } from "discourse/truth-helpers";
import { BUSINESS_OPTIONS } from "discourse/plugins/discourse-professional-network/discourse/lib/options";

const ProfessionalNetworkEditorBusiness = <template>
  <fieldset
    class="professional-network-aspirations professional-network-review"
  >
    <legend>Organisation</legend>

    <details
      class="professional-network-form-section"
      open={{@editor.sectionsExpanded}}
    >
      <summary><span>Organisation accounts</span></summary>
      <div class="professional-network-form-section__body">
        <div class="professional-network-field is-wide">
          <p>Each business or organisation needs its own forum account. Sign in
            or register as the organisation, create its organisation profile,
            then link that account here.</p>
          <label for="professional-network-organization-usernames">Organisation
            account usernames</label>
          <input
            id="professional-network-organization-usernames"
            placeholder="e.g. acme-studio, community-group"
            type="text"
            value={{@editor.organizationUsernamesInput}}
            {{on "input" @editor.changeOrganizationUsernames}}
          />
          <small>Separate multiple usernames with commas. Each account must have
            an organisation profile on this network. Linking accounts does not
            share login access.</small>
        </div>
      </div>
    </details>

    <details
      class="professional-network-form-section"
      open={{@editor.sectionsExpanded}}
    >
      <summary><span>Your business interests</span></summary>
      <div class="professional-network-form-section__body">
        <div class="professional-network-field is-wide">
          <small>Select the opportunities you are personally interested in.
            Products, services, projects, and organisation needs belong on the
            separate organisation profile.</small>
          <div class="professional-network-chips">
            {{#each BUSINESS_OPTIONS as |option|}}
              <label class="professional-network-chip">
                <input
                  checked={{includes @editor.businessInterests option.value}}
                  type="checkbox"
                  {{on
                    "change"
                    (fn @editor.toggleBusinessInterest option.value)
                  }}
                />
                {{option.label}}
              </label>
            {{/each}}
          </div>
        </div>
      </div>
    </details>

  </fieldset>
</template>;

export default ProfessionalNetworkEditorBusiness;
