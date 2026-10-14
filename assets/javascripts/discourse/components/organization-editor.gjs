import { fn } from "@ember/helper";
import { on } from "@ember/modifier";
import { eq } from "discourse/truth-helpers";
import ProfessionalNetworkEditorSettings from "discourse/plugins/discourse-professional-network/discourse/components/editor-settings";
import OrganizationContact from "discourse/plugins/discourse-professional-network/discourse/components/organization-editor-contact";
import OrganizationNeeds from "discourse/plugins/discourse-professional-network/discourse/components/organization-editor-needs";
import OrganizationOfferings from "discourse/plugins/discourse-professional-network/discourse/components/organization-editor-offerings";
import OrganizationOverview from "discourse/plugins/discourse-professional-network/discourse/components/organization-editor-overview";
import OrganizationProjects from "discourse/plugins/discourse-professional-network/discourse/components/organization-editor-projects";

const ProfessionalNetworkOrganizationEditor = <template>
  <section
    class="professional-network-editor professional-network-organization-editor"
    {{on "input" @editor.markDirty}}
    {{on "change" @editor.markDirty}}
  >
    <header>
      <div><p class="professional-network-panel__eyebrow">Organization profile</p><h2
        >Build your network profile</h2><p>Complete each section at your own
          pace and choose when to publish.</p></div>
      <div class="professional-network-progress">
        <span>{{@editor.completionPercent}}% complete</span>
        <progress
          aria-label="Organization profile completeness"
          max="100"
          value={{@editor.completionPercent}}
        ></progress>
        <details class="professional-network-completion"><summary>Profile
            checklist</summary><ul>{{#each
              @editor.completionItems
              as |item|
            }}<li class={{if item.complete "is-complete"}}>{{if
                  item.complete
                  "✓"
                  "○"
                }}
                {{item.label}}</li>{{/each}}</ul></details>
      </div>
    </header>
    <nav
      aria-label="Organization profile sections"
      class="professional-network-tabs"
    >
      <button
        aria-pressed={{eq @editor.organizationTab "overview"}}
        class="btn-flat"
        type="button"
        {{on "click" (fn @editor.showOrganizationTab "overview")}}
      >Overview</button>
      <button
        aria-pressed={{eq @editor.organizationTab "needs"}}
        class="btn-flat"
        type="button"
        {{on "click" (fn @editor.showOrganizationTab "needs")}}
      >Needs & collaboration</button>
      <button
        aria-pressed={{eq @editor.organizationTab "offerings"}}
        class="btn-flat"
        type="button"
        {{on "click" (fn @editor.showOrganizationTab "offerings")}}
      >Offerings</button>
      <button
        aria-pressed={{eq @editor.organizationTab "projects"}}
        class="btn-flat"
        type="button"
        {{on "click" (fn @editor.showOrganizationTab "projects")}}
      >Projects</button>
      <button
        aria-pressed={{eq @editor.organizationTab "contact"}}
        class="btn-flat"
        type="button"
        {{on "click" (fn @editor.showOrganizationTab "contact")}}
      >Links & contact</button>
      <button
        aria-pressed={{eq @editor.organizationTab "settings"}}
        class="btn-flat"
        type="button"
        {{on "click" (fn @editor.showOrganizationTab "settings")}}
      >Settings</button>
    </nav>
    {{#if (eq @editor.organizationTab "overview")}}<OrganizationOverview
        @editor={{@editor}}
      />
    {{else if (eq @editor.organizationTab "needs")}}<OrganizationNeeds
        @editor={{@editor}}
      />
    {{else if (eq @editor.organizationTab "offerings")}}<OrganizationOfferings
        @editor={{@editor}}
      />
    {{else if (eq @editor.organizationTab "projects")}}<OrganizationProjects
        @editor={{@editor}}
      />
    {{else if (eq @editor.organizationTab "contact")}}<OrganizationContact
        @editor={{@editor}}
      />
    {{else}}<ProfessionalNetworkEditorSettings @editor={{@editor}} />{{/if}}
    {{#if @editor.error}}<p
        class="professional-network-error"
        role="alert"
      >{{@editor.error}}</p>{{/if}}
    {{#if @editor.message}}<p
        class="professional-network-success"
        role="status"
      >{{@editor.message}}</p>{{/if}}
    <footer class="professional-network-save-bar"><div><small>{{if
            @editor.dirty
            "You have unsaved changes."
            "All changes saved."
          }}</small></div><div class="professional-network-save-bar__actions"><a
          class="professional-network-public-profile-link"
          href="/u/{{@editor.targetUsername}}/professional-profile"
        >View public profile</a><button
          class="btn btn-primary"
          disabled={{@editor.loading}}
          type="button"
          {{on "click" @editor.save}}
        >{{if @editor.loading "Saving…" "Save profile"}}</button></div></footer>
  </section>
</template>;

export default ProfessionalNetworkOrganizationEditor;
