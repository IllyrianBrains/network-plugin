import { on } from "@ember/modifier";
import ProfessionalNetworkEditorLinkedinCareer from "discourse/plugins/discourse-professional-network/discourse/components/editor-linkedin-career";
import ProfessionalNetworkEditorLinkedinProfile from "discourse/plugins/discourse-professional-network/discourse/components/editor-linkedin-profile";

const ProfessionalNetworkEditorLinkedin = <template>
  <section class="professional-network-linkedin-flow">
    <ProfessionalNetworkEditorLinkedinProfile @editor={{@editor}} />
    <ProfessionalNetworkEditorLinkedinCareer @editor={{@editor}} />

    {{#unless @editor.isEditingOtherUser}}
      <details
        class="professional-network-form-section professional-network-import-section"
      >
        <summary><span>Import a LinkedIn profile PDF</span><small
          >Optional</small></summary>
        <form
          class="professional-network-upload"
          {{on "submit" @editor.upload}}
        >
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
            ><strong>Draft imported.</strong>
              Review the sections above before saving.</p>{{/if}}
        </form>
      </details>
    {{/unless}}
  </section>
</template>;

export default ProfessionalNetworkEditorLinkedin;
