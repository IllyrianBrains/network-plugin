import { fn } from "@ember/helper";
import { on } from "@ember/modifier";
import { includes } from "discourse/truth-helpers";
import {
  MENTORING_OPTIONS,
  MENTORING_TYPE_OPTIONS,
} from "discourse/plugins/discourse-professional-network/discourse/lib/professional-network-mentoring";

const ProfessionalNetworkEditorMentoring = <template>
  <fieldset
    class="professional-network-aspirations professional-network-review"
  >
    <legend>Mentoring</legend>
    <p>Let other members know what you're looking for, or what you can offer.
      Pick as many as apply.</p>

    <details class="professional-network-form-section">
      <summary><span>What are you interested in?</span></summary>
      <div class="professional-network-form-section__body">
        <div class="professional-network-field is-wide">
          <div class="professional-network-chips">
            {{#each MENTORING_OPTIONS as |option|}}
              <label class="professional-network-chip">
                <input
                  checked={{includes @editor.mentoringInterests option.value}}
                  type="checkbox"
                  {{on
                    "change"
                    (fn @editor.toggleMentoringInterest option.value)
                  }}
                />
                {{option.label}}
              </label>
            {{/each}}
          </div>
        </div>
      </div>
    </details>

    <details class="professional-network-form-section">
      <summary><span>What kind of mentoring would you like?</span></summary>
      <div class="professional-network-form-section__body">
        <div class="professional-network-field is-wide">
          <div class="professional-network-chips">
            {{#each MENTORING_TYPE_OPTIONS as |option|}}
              <label class="professional-network-chip">
                <input
                  checked={{includes @editor.mentoringWantedTypes option.value}}
                  type="checkbox"
                  {{on
                    "change"
                    (fn @editor.toggleMentoringWantedType option.value)
                  }}
                />
                {{option.label}}
              </label>
            {{/each}}
          </div>
        </div>
      </div>
    </details>

    <details class="professional-network-form-section">
      <summary><span>What kind of mentoring can you provide?</span></summary>
      <div class="professional-network-form-section__body">
        <div class="professional-network-field is-wide">
          <div class="professional-network-chips">
            {{#each MENTORING_TYPE_OPTIONS as |option|}}
              <label class="professional-network-chip">
                <input
                  checked={{includes
                    @editor.mentoringProvidedTypes
                    option.value
                  }}
                  type="checkbox"
                  {{on
                    "change"
                    (fn @editor.toggleMentoringProvidedType option.value)
                  }}
                />
                {{option.label}}
              </label>
            {{/each}}
          </div>
        </div>
      </div>
    </details>

    <details class="professional-network-form-section">
      <summary><span>Anything else to add?</span></summary>
      <div class="professional-network-form-section__body">
        <div class="professional-network-field is-wide">
          <label for="professional-network-mentoring-note">Mentoring details</label>
          <textarea
            id="professional-network-mentoring-note"
            maxlength="1000"
            placeholder="Describe your mentoring style, cadence, the topics you're most useful for, or what you're hoping to find in a mentor."
            rows="4"
            value={{@editor.mentoringNote}}
            {{on "input" @editor.changeMentoringNote}}
          ></textarea>
          <small>This note is shown on your public profile too.</small>
        </div>
      </div>
    </details>
  </fieldset>
</template>;

export default ProfessionalNetworkEditorMentoring;
