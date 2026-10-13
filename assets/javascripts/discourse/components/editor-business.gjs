import { fn } from "@ember/helper";
import { on } from "@ember/modifier";
import { eq, includes } from "discourse/truth-helpers";
import {
  AVAILABILITY_OPTIONS,
  BUSINESS_OPTIONS,
} from "discourse/plugins/discourse-professional-network/discourse/lib/options";

const ProfessionalNetworkEditorBusiness = <template>
  <fieldset
    class="professional-network-aspirations professional-network-review"
  >
    <legend>Business</legend>

    <details
      class="professional-network-form-section"
      open={{@editor.sectionsExpanded}}
    >
      <summary><span>Business forum account</span></summary>
      <div class="professional-network-form-section__body">
        <div class="professional-network-field is-wide">
          <label for="professional-network-business-username">Business account
            username</label>
          <input
            id="professional-network-business-username"
            maxlength="60"
            placeholder="e.g. acme-studio"
            type="text"
            value={{@editor.businessUsername}}
            {{on "input" @editor.changeBusinessUsername}}
          />
          <small>Must be an existing, separate forum account. Linking it here
            doesn't grant either account access to the other.</small>
        </div>
      </div>
    </details>

    <details
      class="professional-network-form-section"
      open={{@editor.sectionsExpanded}}
    >
      <summary><span>Business opportunities</span></summary>
      <div class="professional-network-form-section__body">
        <div class="professional-network-field is-wide">
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

    <details
      class="professional-network-form-section"
      open={{@editor.sectionsExpanded}}
    >
      <summary><span>Capacity & commercial details</span><small
        >Optional</small></summary>
      <div class="professional-network-form-section__body">
        <div class="professional-network-field">
          <label for="professional-network-availability">Capacity for new client
            or contract work</label>
          <select
            id="professional-network-availability"
            {{on "change" @editor.changeAvailability}}
          >
            <option selected={{eq @editor.availability ""}} value="">Not
              specified</option>
            {{#each AVAILABILITY_OPTIONS as |choice|}}
              <option
                selected={{eq @editor.availability choice.value}}
                value={{choice.value}}
              >{{choice.label}}</option>
            {{/each}}
          </select>
        </div>
        <div class="professional-network-field is-wide">
          <div class="professional-network-chips">
            <label class="professional-network-chip">
              <input
                checked={{@editor.openToConsulting}}
                type="checkbox"
                {{on "change" @editor.changeOpenToConsulting}}
              />
              Open to consulting or advisory work
            </label>
          </div>
        </div>
        <div class="professional-network-field">
          <label for="professional-network-pricing">Pricing or rate</label>
          <input
            id="professional-network-pricing"
            maxlength="60"
            placeholder="e.g. $80–120/hr, fixed price, or contact us"
            type="text"
            value={{@editor.pricing}}
            {{on "input" @editor.changePricing}}
          />
        </div>
        <div class="professional-network-field">
          <label for="professional-network-minimum-engagement">Minimum
            engagement</label>
          <input
            id="professional-network-minimum-engagement"
            maxlength="60"
            placeholder="e.g. $2,000, two weeks, or no minimum"
            type="text"
            value={{@editor.minimumEngagement}}
            {{on "input" @editor.changeMinimumEngagement}}
          />
        </div>
      </div>
    </details>

    <details
      class="professional-network-form-section"
      open={{@editor.sectionsExpanded}}
    >
      <summary><span>Products & services</span><small
        >{{@editor.services.length}}
          added</small></summary>
      <div
        class="professional-network-services professional-network-form-section__body"
      >
        {{#each @editor.services as |offering index|}}
          <div class="professional-network-service-row">
            <input
              placeholder="Offering, e.g. Product design workshop"
              type="text"
              value={{offering.title}}
              {{on "input" (fn @editor.changeServiceField index "title")}}
            />
            <input
              placeholder="Price, e.g. $500 fixed"
              type="text"
              value={{offering.rate}}
              {{on "input" (fn @editor.changeServiceField index "rate")}}
            />
            <textarea
              placeholder="What is included, who it is for, and expected delivery"
              rows="2"
              value={{offering.description}}
              {{on "input" (fn @editor.changeServiceField index "description")}}
            ></textarea>
            <button
              class="btn btn-flat"
              type="button"
              {{on "click" (fn @editor.removeService index)}}
            >Remove</button>
          </div>
        {{else}}
          <p>No products or services added yet.</p>
        {{/each}}
        <button
          class="btn btn-default"
          type="button"
          {{on "click" @editor.addService}}
        >+ Add an offering</button>
      </div>
    </details>
  </fieldset>
</template>;

export default ProfessionalNetworkEditorBusiness;
