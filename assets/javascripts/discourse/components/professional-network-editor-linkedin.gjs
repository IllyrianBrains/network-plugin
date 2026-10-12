import { on } from "@ember/modifier";
import ProfessionalNetworkEditorLinkedinCareer from "discourse/plugins/discourse-professional-network/discourse/components/professional-network-editor-linkedin-career";
import ProfessionalNetworkEditorLinkedinProfile from "discourse/plugins/discourse-professional-network/discourse/components/professional-network-editor-linkedin-profile";

const ProfessionalNetworkEditorLinkedin = <template>
  <section class="professional-network-linkedin-flow">
    <header class="professional-network-linkedin-flow__header">
      <div>
        <p class="professional-network-panel__eyebrow">Profile & career</p>
        <h3>Bring your professional story together</h3>
        <p>Start with a LinkedIn PDF or enter everything manually. You stay in
          control of what is saved and published.</p>
      </div>
      <span class="professional-network-source-badge">Optional import</span>
    </header>

    <details
      class="professional-network-form-section professional-network-import-section"
    >
      <summary><span>Import a LinkedIn profile PDF</span><small>Optional</small></summary>
      <form class="professional-network-upload" {{on "submit" @editor.upload}}>
        <p>The PDF is used only to prepare an editable draft. It is not stored
          with your profile.</p>
        <div class="professional-network-upload__controls"><input
            accept="application/pdf,.pdf"
            aria-describedby="professional-network-pdf-help"
            aria-label="LinkedIn profile PDF"
            id="professional-network-pdf"
            type="file"
            {{on "change" @editor.chooseFile}}
          /><button
            class="btn btn-primary"
            disabled={{@editor.uploadDisabled}}
            type="submit"
          >{{if @editor.loading "Extracting…" "Import PDF"}}</button></div>
        <small id="professional-network-pdf-help">Use the PDF exported from
          your own LinkedIn profile. Selectable text is required.</small>
        {{#if @editor.draft}}<p
            class="professional-network-import-ready"
            role="status"
          ><strong>Draft imported.</strong> Review each section below before
            saving.</p>{{/if}}
      </form>
    </details>

    <div class="professional-network-review-heading">
      <span>Review your profile</span>
      <small>Imported details can be changed or removed</small>
    </div>
    <ProfessionalNetworkEditorLinkedinProfile @editor={{@editor}} />
    <ProfessionalNetworkEditorLinkedinCareer @editor={{@editor}} />
  </section>
</template>;

export default ProfessionalNetworkEditorLinkedin;
