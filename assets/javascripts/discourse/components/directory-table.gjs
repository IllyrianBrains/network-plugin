import { fn } from "@ember/helper";
import { on } from "@ember/modifier";
import { eq, includes } from "discourse/truth-helpers";

const ProfessionalNetworkDirectoryTable = <template>
  <div class="professional-network-directory__table-wrap">
    <table class="professional-network-directory__table">
      <thead>
        <tr>
          <th class="is-expand"></th>
          <th class="is-select">
            <input
              checked={{@directory.allSelected}}
              type="checkbox"
              {{@directory.setIndeterminate @directory.someSelected}}
              {{on "change" @directory.toggleAll}}
            />
          </th>
          <th><button
              type="button"
              {{on "click" (fn @directory.toggleSort "name")}}
            >Name
              {{#if (eq @directory.sortKey "name")}}{{if
                  (eq @directory.sortDirection "asc")
                  "▲"
                  "▼"
                }}{{/if}}
            </button></th>
          <th>Headline</th>
          <th><button
              type="button"
              {{on "click" (fn @directory.toggleSort "company")}}
            >Company
              {{#if (eq @directory.sortKey "company")}}{{if
                  (eq @directory.sortDirection "asc")
                  "▲"
                  "▼"
                }}{{/if}}
            </button></th>
          <th><button
              type="button"
              {{on "click" (fn @directory.toggleSort "city")}}
            >City
              {{#if (eq @directory.sortKey "city")}}{{if
                  (eq @directory.sortDirection "asc")
                  "▲"
                  "▼"
                }}{{/if}}
            </button></th>
          <th><button
              type="button"
              {{on "click" (fn @directory.toggleSort "country")}}
            >Country
              {{#if (eq @directory.sortKey "country")}}{{if
                  (eq @directory.sortDirection "asc")
                  "▲"
                  "▼"
                }}{{/if}}
            </button></th>
          <th><button
              type="button"
              {{on "click" (fn @directory.toggleSort "experience_level")}}
            >Level
              {{#if (eq @directory.sortKey "experience_level")}}{{if
                  (eq @directory.sortDirection "asc")
                  "▲"
                  "▼"
                }}{{/if}}
            </button></th>
          <th>Availability</th>
          <th>Membership</th>
          <th>Status</th>
          <th>Fields of expertise</th>
          <th>Skills</th>
        </tr>
      </thead>
      <tbody>
        {{#each @directory.rows as |row|}}
          <tr
            class={{if
              (includes @directory.selected row.username)
              "is-selected"
            }}
          >
            <td class="is-expand">
              <button
                title={{if
                  (includes @directory.expanded row.username)
                  "Collapse details"
                  "Expand details"
                }}
                type="button"
                {{on "click" (fn @directory.toggleExpand row.username)}}
              >{{if
                  (includes @directory.expanded row.username)
                  "▾"
                  "▸"
                }}</button>
            </td>
            <td class="is-select">
              <input
                checked={{includes @directory.selected row.username}}
                type="checkbox"
                {{on "change" (fn @directory.toggleRow row.username)}}
              />
            </td>
            <td><a
                href="/u/{{row.username}}/professional-profile"
              >{{row.name}}</a></td>
            <td title={{row.headline}}>{{row.headline}}</td>
            <td title={{row.company}}>{{row.company}}</td>
            <td>{{row.city}}</td>
            <td>{{row.country}}</td>
            <td>{{row.experienceLabel}}</td>
            <td>{{row.availabilityLabel}}</td>
            <td>{{row.membershipType}}</td>
            <td>
              {{#each row.badges as |badge|}}
                <span
                  class="professional-network-directory__badge
                    {{if
                      (eq badge 'Unpublished')
                      'professional-network-directory__badge--unpublished'
                    }}"
                >{{badge}}</span>
              {{/each}}
            </td>
            <td>
              <div class="professional-network-tags">
                {{#each row.fieldsOfExpertise as |field|}}
                  <button
                    title="Filter the directory by this field"
                    type="button"
                    {{on "click" (fn @directory.filterByField field)}}
                  >{{field}}</button>
                {{/each}}
              </div>
            </td>
            <td>
              <div class="professional-network-tags">
                {{#each row.visibleSkills as |skill|}}
                  <button
                    title="Filter the directory by this skill"
                    type="button"
                    {{on "click" (fn @directory.filterBySkill skill)}}
                  >{{skill}}</button>
                {{/each}}
                {{#if row.hiddenSkillCount}}
                  <span
                    class="professional-network-directory__more-skills"
                  >+{{row.hiddenSkillCount}}</span>
                {{/if}}
              </div>
            </td>
          </tr>
          {{#if (includes @directory.expanded row.username)}}
            <tr class="professional-network-directory__detail-row">
              <td colspan="13">
                <div class="professional-network-directory__detail">
                  {{#if row.about}}<p>{{row.about}}</p>{{/if}}
                  <dl>
                    {{#if row.industryRole}}
                      <div><dt>Industry / role</dt><dd
                        >{{row.industryRole}}</dd></div>
                    {{/if}}
                    {{#if row.timezone}}
                      <div><dt>Timezone</dt><dd>{{row.timezone}}</dd></div>
                    {{/if}}
                    {{#if row.canHelpWith}}
                      <div><dt>Can help with</dt><dd
                        >{{row.canHelpWith}}</dd></div>
                    {{/if}}
                    {{#if row.lookingFor}}
                      <div><dt>Looking for</dt><dd>{{row.lookingFor}}</dd></div>
                    {{/if}}
                    {{#if row.idealConnection}}
                      <div><dt>Ideal connection</dt><dd
                        >{{row.idealConnection}}</dd></div>
                    {{/if}}
                    {{#if row.aspirationField}}
                      <div><dt>Career aspiration</dt><dd
                        >{{row.aspirationField}}{{#if row.aspirationSubfield}}
                            ·
                            {{row.aspirationSubfield}}{{/if}}</dd></div>
                    {{/if}}
                  </dl>
                  {{#if row.languages.length}}
                    <div class="professional-network-directory__detail-group">
                      <strong>Languages</strong>
                      <div class="professional-network-tags">
                        {{#each row.languages as |language|}}<span
                          >{{language}}</span>{{/each}}
                      </div>
                    </div>
                  {{/if}}
                  {{#if row.certifications.length}}
                    <div class="professional-network-directory__detail-group">
                      <strong>Certifications</strong>
                      <div class="professional-network-tags">
                        {{#each row.certifications as |cert|}}<span
                          >{{cert}}</span>{{/each}}
                      </div>
                    </div>
                  {{/if}}
                  {{#if row.mentoringInterestLabels.length}}
                    <div class="professional-network-directory__detail-group">
                      <strong>Mentoring</strong>
                      <div class="professional-network-tags">
                        {{#each row.mentoringInterestLabels as |label|}}<span
                          >{{label}}</span>{{/each}}
                      </div>
                    </div>
                  {{/if}}
                  {{#if row.businessInterestLabels.length}}
                    <div class="professional-network-directory__detail-group">
                      <strong>Looking for (introductions)</strong>
                      <div class="professional-network-tags">
                        {{#each row.businessInterestLabels as |label|}}<span
                          >{{label}}</span>{{/each}}
                      </div>
                    </div>
                  {{/if}}
                  {{#if row.links.length}}
                    <div class="professional-network-directory__detail-links">
                      {{#each row.links as |link|}}
                        <a
                          class="btn btn-default"
                          href={{link.url}}
                          rel="noopener noreferrer"
                          target="_blank"
                        >{{link.label}}</a>
                      {{/each}}
                    </div>
                  {{/if}}
                </div>
              </td>
            </tr>
          {{/if}}
        {{else}}
          <tr><td colspan="13">No members match these filters.</td></tr>
        {{/each}}
      </tbody>
    </table>
  </div>
</template>;

export default ProfessionalNetworkDirectoryTable;
