import { or } from "discourse/truth-helpers";

const ProfessionalNetworkPanelLinkedin = <template>
  <div class="professional-network-panel__linkedin-section">
    <details class="professional-network-form-section">
      <summary><span>LinkedIn profile</span><small>Experience, education, and
          skills</small></summary>
      <div class="professional-network-form-section__linkedin">
        <h3>Experience</h3>
        <div class="professional-network-list">{{#each
            @panel.profile.experience
            as |job|
          }}<article><h3>{{or job.title job.role}}</h3><p
              >{{job.organization}}</p><small>{{job.start_year}}{{#if
                  job.start_year
                }}–{{/if}}{{if
                  job.is_current
                  "Present"
                  job.end_year
                }}</small></article>{{else}}<p>No experience added.</p>{{/each}}</div>
        {{#if @panel.profile.volunteering.length}}<h3>Volunteering</h3><div
            class="professional-network-list"
          >{{#each @panel.profile.volunteering as |role|}}<article><h3
                >{{role.role}}</h3><p>{{role.organization}}
                  ·
                  {{role.cause}}</p></article>{{/each}}</div>{{/if}}

        <h3>Education</h3>
        <div class="professional-network-list">{{#each
            @panel.profile.education
            as |school|
          }}<article><h3>{{or school.school school.institution}}</h3><p
              >{{school.degree}}{{#if school.field}}
                  ·
                  {{school.field}}{{/if}}</p></article>{{else}}<p>No education
              added.</p>{{/each}}</div>

        <h3>Skills</h3>
        {{#if @panel.profile.fields_of_expertise.length}}<h4>Fields of expertise</h4><div
            class="professional-network-tags"
          >{{#each @panel.profile.fields_of_expertise as |field|}}<span
              >{{field}}</span>{{/each}}</div>{{/if}}
        <div class="professional-network-tags">{{#each
            @panel.profile.skills
            as |skill|
          }}<span>{{skill}}</span>{{else}}<p>No skills added.</p>{{/each}}</div>
        {{#if @panel.profile.languages.length}}<h4>Languages</h4><div
            class="professional-network-tags"
          >{{#each @panel.profile.languages as |language|}}<span
              >{{language}}</span>{{/each}}</div>{{/if}}
        {{#if @panel.profile.certifications.length}}<h4>Certifications</h4><div
            class="professional-network-list"
          >{{#each @panel.profile.certifications as |cert|}}<article
              >{{cert}}</article>{{/each}}</div>{{/if}}
        {{#if @panel.profile.honors.length}}<h4>Honors & awards</h4><div
            class="professional-network-list"
          >{{#each @panel.profile.honors as |honor|}}<article
              >{{honor.title}}<small>
                  {{honor.issuer}}
                  {{honor.year}}</small></article>{{/each}}</div>{{/if}}
      </div>
    </details>
  </div>
</template>;

export default ProfessionalNetworkPanelLinkedin;
