import { on } from "@ember/modifier";
import ProfessionalNetworkEditorLinkedinCareer from "discourse/plugins/discourse-professional-network/discourse/components/editor-linkedin-career";
import ProfessionalNetworkEditorLinkedinProfile from "discourse/plugins/discourse-professional-network/discourse/components/editor-linkedin-profile";
import ProfessionalNetworkEditorStatus from "discourse/plugins/discourse-professional-network/discourse/components/editor-status";

const ProfessionalNetworkEditorLinkedin = <template>
  <section class="professional-network-linkedin-flow">
    <ProfessionalNetworkEditorLinkedinProfile @editor={{@editor}} />
    <ProfessionalNetworkEditorLinkedinCareer @editor={{@editor}} />
    <ProfessionalNetworkEditorStatus @editor={{@editor}} />

    {{#unless @editor.isEditingOtherUser}}
      <fieldset
        class="professional-network-aspirations professional-network-review professional-network-import-section"
      >
        <legend>Import profile</legend>
        <details
          class="professional-network-form-section"
          open={{@editor.sectionsExpanded}}
        >
          <summary><span>LinkedIn PDF</span><small>Available now</small></summary>
          <form
            class="professional-network-upload"
            {{on "submit" @editor.upload}}
          >
            <p>The PDF prepares an editable draft containing basic information,
              your LinkedIn URL, skills, certifications, experience, and
              education. It is not stored with your profile.</p>
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
        <details class="professional-network-form-section">
          <summary><span>Europass CV</span><small>Coming later</small></summary>
          <div class="professional-network-form-section__body">
            <p>Importing a Europass CV is planned for a later release.</p>
          </div>
        </details>
      </fieldset>
    {{/unless}}
  </section>
</template>;

export default ProfessionalNetworkEditorLinkedin;
