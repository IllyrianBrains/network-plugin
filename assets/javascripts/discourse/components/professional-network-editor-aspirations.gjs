import { fn } from "@ember/helper";
import { on } from "@ember/modifier";

const ProfessionalNetworkEditorAspirations = <template>
  <fieldset
    class="professional-network-aspirations professional-network-review"
  >
    <legend>Next step</legend>
    <p>Share where you're headed and what you'd like to do next, so other
      members can find you and help.</p>

    <details class="professional-network-form-section">
      <summary><span>Target field</span></summary>
      <div class="professional-network-form-section__body">
        <div class="professional-network-field">
          <label for="professional-network-aspiration-field">Field you're aiming
            for</label>
          <input
            id="professional-network-aspiration-field"
            placeholder="e.g. Engineering Leadership"
            type="text"
            value={{@editor.aspirationField}}
            {{on "input" @editor.changeAspirationField}}
          />
        </div>
        <div class="professional-network-field">
          <label for="professional-network-aspiration-subfield">Subfield</label>
          <input
            id="professional-network-aspiration-subfield"
            maxlength="120"
            placeholder="e.g. Data science, cardiology"
            type="text"
            value={{@editor.aspirationSubfield}}
            {{on "input" @editor.changeAspirationSubfield}}
          />
        </div>
      </div>
    </details>

    <details class="professional-network-form-section">
      <summary><span>What's your next step?</span></summary>
      <div class="professional-network-form-section__body">
        <div class="professional-network-field is-wide">
          <label for="professional-network-aspirations-note">Details</label>
          <textarea
            id="professional-network-aspirations-note"
            maxlength="1000"
            placeholder="The concrete next step I'm trying to take: …&#10;City or format: …&#10;Timeline: …&#10;What I've tried so far: …"
            rows="7"
            value={{@editor.aspirationsNote}}
            {{on "input" @editor.changeAspirationsNote}}
          ></textarea>
          <small>This note is shown on your public profile too.</small>
        </div>
      </div>
    </details>
  </fieldset>
</template>;

export default ProfessionalNetworkEditorAspirations;
