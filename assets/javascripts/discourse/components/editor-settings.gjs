import { on } from "@ember/modifier";
import { eq } from "discourse/truth-helpers";

const ProfessionalNetworkEditorSettings = <template>
  <fieldset
    class="professional-network-aspirations professional-network-review professional-network-settings"
  >
    <legend>Settings</legend>

    <section class="professional-network-settings__section">
      <div>
        <h3>Directory visibility</h3>
        <p>Discoverable in the public
          {{if (eq @editor.accountType "organization") "organization" "member"}}
          directory.</p>
      </div>
      <label class="professional-network-visibility"><input
          checked={{@editor.publicProfile}}
          type="checkbox"
          {{on "change" @editor.changeVisibility}}
        />Visible in the public directory</label>
    </section>

    <section class="professional-network-settings__section">
      <div>
        <h3>Profile type</h3>
      </div>
      <span class="professional-network-settings__value">{{if
          (eq @editor.accountType "organization")
          "Organization"
          "Person"
        }}</span>
    </section>

    <section class="professional-network-reset-zone">
      <div>
        <h3>Reset professional profile</h3>
        <p>Permanently deletes this profile. You'll need to choose Person or
          Organization again.</p>
      </div>
      <button
        class="btn btn-danger"
        disabled={{@editor.loading}}
        type="button"
        {{on "click" @editor.resetProfile}}
      >Reset</button>
    </section>
  </fieldset>
</template>;

export default ProfessionalNetworkEditorSettings;
