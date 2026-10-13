import { fn } from "@ember/helper";
import { on } from "@ember/modifier";
import { eq } from "discourse/truth-helpers";
import ProfessionalNetworkAccountType from "discourse/plugins/discourse-professional-network/discourse/components/account-type";
import ProfessionalNetworkEditorAspirations from "discourse/plugins/discourse-professional-network/discourse/components/editor-aspirations";
import ProfessionalNetworkEditorBusiness from "discourse/plugins/discourse-professional-network/discourse/components/editor-business";
import ProfessionalNetworkEditorIntroductions from "discourse/plugins/discourse-professional-network/discourse/components/editor-introductions";
import ProfessionalNetworkEditorLinkedin from "discourse/plugins/discourse-professional-network/discourse/components/editor-linkedin";
import ProfessionalNetworkEditorMentoring from "discourse/plugins/discourse-professional-network/discourse/components/editor-mentoring";
import ProfessionalNetworkEditorRecommendationPriorities from "discourse/plugins/discourse-professional-network/discourse/components/editor-recommendation-priorities";
import ProfessionalNetworkEditorReturn from "discourse/plugins/discourse-professional-network/discourse/components/editor-return";
import ProfessionalNetworkEditorSettings from "discourse/plugins/discourse-professional-network/discourse/components/editor-settings";
import ProfessionalNetworkEditorStatus from "discourse/plugins/discourse-professional-network/discourse/components/editor-status";
import ProfessionalNetworkOrganizationEditor from "discourse/plugins/discourse-professional-network/discourse/components/organization-editor";
import ProfessionalNetworkEditorPersistence from "discourse/plugins/discourse-professional-network/discourse/lib/editor-persistence";

export default class ProfessionalNetworkEditor extends ProfessionalNetworkEditorPersistence {
  <template>
    {{#if this.profileLoaded}}
      {{#if this.isEditingOtherUser}}
        <div class="professional-network-admin-edit-notice" role="status">
          Editing
          <strong>{{this.targetUsername}}</strong>'s professional profile as an
          admin. LinkedIn PDF import is unavailable here; ask the member to
          import it themselves.
        </div>
      {{/if}}
      {{#if this.accountType}}
        {{#if (eq this.accountType "organization")}}
          <ProfessionalNetworkOrganizationEditor @editor={{this}} />
        {{else}}
          <section
            class="professional-network-editor"
            {{on "change" this.markDirty}}
            {{on "input" this.markDirty}}
          >
            <header>
              <div>
                <p class="professional-network-panel__eyebrow">Professional
                  profile</p>
                <h2>Edit profile</h2>
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
                      <li class={{if item.complete "is-complete"}}>{{if
                          item.complete
                          "✓"
                          "○"
                        }}
                        {{item.label}}</li>
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
              >Profile</button>
              <button
                aria-pressed={{eq this.activeTab "networking"}}
                class="btn-flat"
                type="button"
                {{on "click" (fn this.showTab "networking")}}
              >Connections</button>
              <button
                aria-pressed={{eq this.activeTab "status"}}
                class="btn-flat"
                type="button"
                {{on "click" (fn this.showTab "status")}}
              >Status</button>
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
              <button
                aria-pressed={{eq this.activeTab "settings"}}
                class="btn-flat"
                type="button"
                {{on "click" (fn this.showTab "settings")}}
              >Settings</button>
            </nav>

            {{#if this.hasCollapsibleSections}}
              <div class="professional-network-section-toggle">
                <button
                  class="btn btn-flat"
                  type="button"
                  {{on "click" this.toggleSectionsExpanded}}
                >{{if this.sectionsExpanded "Collapse all" "Edit all"}}</button>
              </div>
            {{/if}}

            {{#if (eq this.activeTab "linkedin")}}
              <ProfessionalNetworkEditorLinkedin @editor={{this}} />
            {{else if (eq this.activeTab "networking")}}
              <ProfessionalNetworkEditorRecommendationPriorities
                @editor={{this}}
              />
              <ProfessionalNetworkEditorIntroductions @editor={{this}} />
            {{else if (eq this.activeTab "status")}}
              <ProfessionalNetworkEditorStatus @editor={{this}} />
              <ProfessionalNetworkEditorAspirations @editor={{this}} />
            {{else if (eq this.activeTab "business")}}
              <ProfessionalNetworkEditorBusiness @editor={{this}} />
            {{else if (eq this.activeTab "mentoring")}}
              <ProfessionalNetworkEditorMentoring @editor={{this}} />
            {{else if (eq this.activeTab "return")}}
              <ProfessionalNetworkEditorReturn @editor={{this}} />
            {{else}}
              <ProfessionalNetworkEditorSettings @editor={{this}} />
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
                {{#if this.dirty}}<small>You have unsaved changes.</small>{{else}}<small
                  >All changes saved.</small>{{/if}}
              </div>
              <div class="professional-network-save-bar__actions">
                <a
                  class="professional-network-public-profile-link"
                  href="/u/{{this.currentUser.username}}/professional-network"
                >View public profile</a>
                <button
                  class="btn btn-primary"
                  disabled={{this.loading}}
                  type="button"
                  {{on "click" this.save}}
                >{{if this.loading "Saving…" "Save profile"}}</button>
              </div>
            </footer>
          </section>
        {{/if}}
      {{else}}
        <ProfessionalNetworkAccountType @editor={{this}} />
      {{/if}}
    {{/if}}
  </template>
}
