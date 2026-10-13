import { array, fn } from "@ember/helper";
import { on } from "@ember/modifier";
import { eq, includes } from "discourse/truth-helpers";
import {
  RETURN_COUNTRY_OPTIONS,
  RETURN_PLAN_OPTIONS,
} from "discourse/plugins/discourse-professional-network/discourse/lib/options";

const ProfessionalNetworkEditorReturn = <template>
  <fieldset class="professional-network-aspirations">
    <legend>Return plan
      <span class="professional-network-private">Private</span></legend>
    <p>Not published — only you and the network team can see this.</p>

    <p>Thinking of moving back?</p>
    <div class="professional-network-chips">
      {{#each RETURN_PLAN_OPTIONS as |option|}}
        <label class="professional-network-chip">
          <input
            checked={{eq @editor.returnPlan option.value}}
            name="professional-network-return-plan"
            type="radio"
            value={{option.value}}
            {{on "change" @editor.changeReturnPlan}}
          />
          {{option.label}}
        </label>
      {{/each}}
    </div>

    {{#if (includes (array "yes" "maybe" "already_there") @editor.returnPlan)}}
      <p>Where?</p>
      <div class="professional-network-chips">
        {{#each RETURN_COUNTRY_OPTIONS as |option|}}
          <label class="professional-network-chip">
            <input
              checked={{includes @editor.returnCountries option.value}}
              type="checkbox"
              {{on "change" (fn @editor.toggleReturnCountry option.value)}}
            />
            {{option.label}}
          </label>
        {{/each}}
      </div>
    {{/if}}
  </fieldset>
</template>;

export default ProfessionalNetworkEditorReturn;
