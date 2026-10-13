import { array, fn } from "@ember/helper";
import { on } from "@ember/modifier";
import { eq } from "discourse/truth-helpers";

const OrganizationOfferings = <template>
  <fieldset
    class="professional-network-aspirations professional-network-review"
  >
    <legend>Offerings</legend><p>Share what the organization provides and the
      opportunities available.</p>
    <details class="professional-network-form-section" open><summary><span
        >Products & services</span></summary><div
        class="professional-network-form-section__body"
      ><div class="professional-network-field is-wide"><label
            for="professional-network-organization-offerings"
          >Products and services offered</label><input
            id="professional-network-organization-offerings"
            placeholder="Consulting, training, software, workspace"
            type="text"
            value={{@editor.organizationOfferingsInput}}
            {{on
              "input"
              (fn @editor.changeOrganizationList "organization_offerings")
            }}
          /><small>Separate items with commas.</small></div></div></details>
    <details class="professional-network-form-section"><summary><span>Current
          opportunity topics</span></summary><div
        class="professional-network-form-section__body"
      ><div class="professional-network-field is-wide"><label
            for="professional-network-organization-opportunities"
          >Opportunities</label><input
            id="professional-network-organization-opportunities"
            placeholder="Jobs, internships, events, projects, volunteering"
            type="text"
            value={{@editor.organizationOpportunitiesInput}}
            {{on
              "input"
              (fn @editor.changeOrganizationList "organization_opportunities")
            }}
          /><small>Separate items with commas.</small></div></div></details>
    <details class="professional-network-form-section"><summary><span>Detailed
          opportunities</span><small>Jobs, events, projects, and calls for
          collaboration</small></summary><div
        class="professional-network-form-section__body"
      ><div class="professional-network-services">
          {{#each
            @editor.profileData.organization_opportunity_details
            as |opportunity index|
          }}
            <article class="professional-network-service-row">
              <label>Type<select
                  {{on
                    "change"
                    (fn
                      @editor.changeEntry
                      "organization_opportunity_details"
                      index
                      "kind"
                    )
                  }}
                >
                  <option value="">Select a type</option>
                  {{#each
                    (array
                      "job"
                      "internship"
                      "event"
                      "project"
                      "volunteer"
                      "benefit"
                      "collaboration"
                      "mentoring"
                    )
                    as |kind|
                  }}<option
                      selected={{eq opportunity.kind kind}}
                      value={{kind}}
                    >{{kind}}</option>{{/each}}
                </select></label>
              <label>Title<input
                  type="text"
                  value={{opportunity.title}}
                  {{on
                    "input"
                    (fn
                      @editor.changeEntry
                      "organization_opportunity_details"
                      index
                      "title"
                    )
                  }}
                /></label>
              <label class="is-wide">Description<textarea
                  rows="3"
                  value={{opportunity.description}}
                  {{on
                    "input"
                    (fn
                      @editor.changeEntry
                      "organization_opportunity_details"
                      index
                      "description"
                    )
                  }}
                ></textarea></label>
              <label>Link<input
                  type="url"
                  value={{opportunity.url}}
                  {{on
                    "input"
                    (fn
                      @editor.changeEntry
                      "organization_opportunity_details"
                      index
                      "url"
                    )
                  }}
                /></label>
              <label>Closing date<input
                  type="date"
                  value={{opportunity.expires_on}}
                  {{on
                    "input"
                    (fn
                      @editor.changeEntry
                      "organization_opportunity_details"
                      index
                      "expires_on"
                    )
                  }}
                /></label>
              <button
                class="btn btn-flat"
                type="button"
                {{on
                  "click"
                  (fn
                    @editor.removeEntry "organization_opportunity_details" index
                  )
                }}
              >Remove opportunity</button>
            </article>
          {{else}}<p>No detailed opportunities added yet.</p>{{/each}}
          <button
            class="btn btn-default"
            type="button"
            {{on
              "click"
              (fn @editor.addEntry "organization_opportunity_details")
            }}
          >+ Add an opportunity</button>
        </div></div></details>
  </fieldset>
</template>;

export default OrganizationOfferings;
