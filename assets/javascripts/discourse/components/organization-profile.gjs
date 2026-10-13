import { or } from "discourse/truth-helpers";

const ProfessionalNetworkOrganizationProfile = <template>
  <div class="professional-network-panel__sections">
    {{#if
      (or
        @panel.profile.mission
        @panel.profile.about
        @panel.organizationTypeLabel
        @panel.profile.sector
        @panel.profile.stage
      )
    }}
      <details class="professional-network-form-section"><summary><span>About
            the organization</span></summary><div
          class="professional-network-list"
        >
          {{#if @panel.profile.mission}}<article><h3>Mission</h3><p
              >{{@panel.profile.mission}}</p></article>{{/if}}
          {{#if @panel.profile.about}}<article><h3>Description</h3><p
              >{{@panel.profile.about}}</p></article>{{/if}}
          {{#if
            (or
              @panel.organizationTypeLabel
              @panel.profile.sector
              @panel.profile.stage
            )
          }}<article><h3>Organization</h3><p
              >{{@panel.organizationTypeLabel}}{{#if @panel.profile.sector}}
                  ·
                  {{@panel.profile.sector}}{{/if}}{{#if @panel.profile.stage}}
                  ·
                  {{@panel.profile.stage}}{{/if}}</p></article>{{/if}}
        </div></details>
    {{/if}}
    {{#if @panel.profile.organization_needs.length}}
      <details class="professional-network-form-section"><summary><span>Current
            needs</span></summary><div class="professional-network-tags">{{#each
            @panel.profile.organization_needs
            as |item|
          }}<span>{{item}}</span>{{/each}}</div></details>
    {{/if}}
    {{#if @panel.profile.organization_offerings.length}}
      <details class="professional-network-form-section"><summary><span>Products
            & services</span></summary><div
          class="professional-network-tags"
        >{{#each @panel.profile.organization_offerings as |item|}}<span
            >{{item}}</span>{{/each}}</div></details>
    {{/if}}
    {{#if @panel.profile.organization_opportunities.length}}
      <details class="professional-network-form-section"><summary><span
          >Opportunities</span></summary><div
          class="professional-network-tags"
        >{{#each @panel.profile.organization_opportunities as |item|}}<span
            >{{item}}</span>{{/each}}</div></details>
    {{/if}}
    {{#if @panel.profile.organization_opportunity_details.length}}
      <details class="professional-network-form-section" open><summary><span
          >Open opportunities</span><small
          >{{@panel.profile.organization_opportunity_details.length}}
            shared</small></summary><div class="professional-network-list">
          {{#each
            @panel.profile.organization_opportunity_details
            as |opportunity|
          }}
            <article><h3>{{opportunity.title}}</h3><small
              >{{opportunity.kind}}{{#if opportunity.expires_on}}
                  · Closes
                  {{opportunity.expires_on}}{{/if}}</small>{{#if
                opportunity.description
              }}<p>{{opportunity.description}}</p>{{/if}}{{#if
                opportunity.url
              }}<p><a
                    href={{opportunity.url}}
                    rel="noopener noreferrer"
                    target="_blank"
                  >View opportunity</a></p>{{/if}}</article>
          {{/each}}
        </div></details>
    {{/if}}
    {{#if @panel.profile.collaboration_interests.length}}
      <details class="professional-network-form-section"><summary><span
          >Collaboration interests</span></summary><div
          class="professional-network-tags"
        >{{#each @panel.profile.collaboration_interests as |item|}}<span
            >{{item}}</span>{{/each}}</div></details>
    {{/if}}
    {{#if @panel.profile.organization_projects.length}}
      <details class="professional-network-form-section" open><summary><span
          >Projects</span><small>{{@panel.profile.organization_projects.length}}
            shared</small></summary><div class="professional-network-list">
          {{#each @panel.profile.organization_projects as |project|}}
            <article><h3>{{project.name}}</h3>{{#if project.description}}<p
                >{{project.description}}</p>{{/if}}{{#if project.upcoming}}<p
                  class="professional-network-project-upcoming"
                ><strong>Coming up next</strong><br
                  />{{project.upcoming}}</p>{{/if}}</article>
          {{/each}}
        </div></details>
    {{/if}}
    {{#if @panel.linkedMembers.length}}
      <details class="professional-network-form-section"><summary><span>Linked
            members</span><small
          >{{@panel.linkedMembers.length}}</small></summary><div
          class="professional-network-list"
        >
          {{#each @panel.linkedMembers as |member|}}
            <article><h3><a
                  href="/u/{{member.username}}"
                >{{member.name}}</a></h3>{{#if member.headline}}<p
                >{{member.headline}}</p>{{/if}}</article>
          {{/each}}
        </div></details>
    {{/if}}
  </div>
</template>;

export default ProfessionalNetworkOrganizationProfile;
