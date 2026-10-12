import { fn } from "@ember/helper";
import { on } from "@ember/modifier";
import { eq } from "discourse/truth-helpers";
import ProfessionalNetworkEditorAspirations from "discourse/plugins/discourse-professional-network/discourse/components/professional-network-editor-aspirations";
import ProfessionalNetworkEditorBusiness from "discourse/plugins/discourse-professional-network/discourse/components/professional-network-editor-business";
import ProfessionalNetworkEditorIntroductions from "discourse/plugins/discourse-professional-network/discourse/components/professional-network-editor-introductions";
import ProfessionalNetworkEditorLinkedin from "discourse/plugins/discourse-professional-network/discourse/components/professional-network-editor-linkedin";
import ProfessionalNetworkEditorMentoring from "discourse/plugins/discourse-professional-network/discourse/components/professional-network-editor-mentoring";
import ProfessionalNetworkEditorReturn from "discourse/plugins/discourse-professional-network/discourse/components/professional-network-editor-return";
import ProfessionalNetworkEditorStatus from "discourse/plugins/discourse-professional-network/discourse/components/professional-network-editor-status";
import ProfessionalNetworkEditorPersistence from "discourse/plugins/discourse-professional-network/discourse/lib/professional-network-editor-persistence";

export default class ProfessionalNetworkEditor extends ProfessionalNetworkEditorPersistence {
  <template>
    <section
      class="professional-network-editor"
      {{on "change" this.markDirty}}
      {{on "input" this.markDirty}}
    >
      <header>
        <div>
          <p class="professional-network-panel__eyebrow">Professional profile</p>
          <h2>Build your network profile</h2>
          <p>Import your LinkedIn PDF or complete each section at your own pace.</p>
        </div>
        <div class="professional-network-progress">
          <span>{{this.completionPercent}}% complete</span>
          <progress
            aria-label="Profile completeness"
            max="100"
            value={{this.completionPercent}}
          ></progress>
          <details class="professional-network-completion">
            <summary>Profile checklist</summary>
            <ul>
              {{#each this.completionItems as |item|}}
                <li class={{if item.complete "is-complete"}}>
                  {{if item.complete "✓" "○"}}
                  {{item.label}}
                </li>
              {{/each}}
            </ul>
          </details>
        </div>
      </header>

      <nav
        aria-label="Professional profile sections"
        class="professional-network-tabs"
      >
        <button
          aria-pressed={{eq this.activeTab "linkedin"}}
          class="btn-flat"
          type="button"
          {{on "click" (fn this.showTab "linkedin")}}
        >Profile & career</button>
        <button
          aria-pressed={{eq this.activeTab "networking"}}
          class="btn-flat"
          type="button"
          {{on "click" (fn this.showTab "networking")}}
        >Networking</button>
        <button
          aria-pressed={{eq this.activeTab "status"}}
          class="btn-flat"
          type="button"
          {{on "click" (fn this.showTab "status")}}
        >Status & links</button>
        <button
          aria-pressed={{eq this.activeTab "business"}}
          class="btn-flat"
          type="button"
          {{on "click" (fn this.showTab "business")}}
        >Business</button>
        <button
          aria-pressed={{eq this.activeTab "mentoring"}}
          class="btn-flat"
          type="button"
          {{on "click" (fn this.showTab "mentoring")}}
        >Mentoring</button>
        <button
          aria-pressed={{eq this.activeTab "return"}}
          class="btn-flat"
          type="button"
          {{on "click" (fn this.showTab "return")}}
        >Return plan</button>
      </nav>

      {{#if (eq this.activeTab "linkedin")}}
        <ProfessionalNetworkEditorLinkedin @editor={{this}} />
      {{else if (eq this.activeTab "networking")}}
        <ProfessionalNetworkEditorIntroductions @editor={{this}} />
        <ProfessionalNetworkEditorAspirations @editor={{this}} />
      {{else if (eq this.activeTab "status")}}
        <ProfessionalNetworkEditorStatus @editor={{this}} />
      {{else if (eq this.activeTab "business")}}
        <ProfessionalNetworkEditorBusiness @editor={{this}} />
      {{else if (eq this.activeTab "mentoring")}}
        <ProfessionalNetworkEditorMentoring @editor={{this}} />
      {{else}}
        <ProfessionalNetworkEditorReturn @editor={{this}} />
      {{/if}}

      {{#if this.error}}<p
          class="professional-network-error"
          role="alert"
        >{{this.error}}</p>{{/if}}
      {{#if this.message}}<p
          class="professional-network-success"
          role="status"
        >{{this.message}}</p>{{/if}}

      <footer class="professional-network-save-bar">
        <div>
          <label class="professional-network-visibility"><input
              checked={{this.publicProfile}}
              type="checkbox"
              {{on "change" this.changeVisibility}}
            />
            Visible in the public member directory</label>
          {{#if this.dirty}}<small>You have unsaved changes.</small>{{else}}<small
            >All changes saved.</small>{{/if}}
        </div>
        <button
          class="btn btn-primary"
          disabled={{this.loading}}
          type="button"
          {{on "click" this.save}}
        >{{if this.loading "Saving…" "Save profile"}}</button>
      </footer>
    </section>
  </template>
}
