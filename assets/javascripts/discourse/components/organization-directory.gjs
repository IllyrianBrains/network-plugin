import { service } from "@ember/service";
import { eq } from "discourse/truth-helpers";
import OrganizationDirectoryFilters from "discourse/plugins/discourse-professional-network/discourse/components/organization-directory-filters";
import OrganizationDirectoryState from "discourse/plugins/discourse-professional-network/discourse/lib/organization-directory-state";

export default class ProfessionalNetworkOrganizationDirectory extends OrganizationDirectoryState {
  @service siteSettings;

  <template>
    <div
      class="professional-network-directory professional-network-organization-directory"
    >
      <header>
        <p class="professional-network-panel__eyebrow">{{this.siteSettings.professional_network_name}}</p>
        <h2>Organizations</h2>
        <p>Discover businesses, NGOs, member networks, and community
          organizations.</p>
      </header>
      <nav
        aria-label="Directory type"
        class="professional-network-directory-switcher"
      >
        <a class="btn btn-flat" href="/network/directory">Members</a>
        <a
          aria-current="page"
          class="btn btn-flat"
          href="/network/organizations"
        >Organizations</a>
      </nav>
      <OrganizationDirectoryFilters @directory={{this}} />
      {{#if this.error}}
        <p class="professional-network-error" role="alert">Could not load the
          organization directory.</p>
      {{else if this.loading}}
        <p class="professional-network-graph__status">Loading organizations…</p>
      {{else if this.searched}}
        <p
          class="professional-network-graph__status professional-network-organization-directory__count"
        >{{this.resultCount}}
          organization{{if (eq this.resultCount 1) "" "s"}}</p>
        <div class="professional-network-organization-directory__grid">
          {{#each this.organizations as |result|}}
            <article class="professional-network-organization-card">
              <div>
                <p
                  class="professional-network-panel__eyebrow"
                >{{result.organizationTypeLabel}}</p>
                <h3><a
                    href="/u/{{result.username}}/professional-profile"
                  >{{result.profile.name}}</a></h3>
                {{#if result.profile.mission}}<p
                    class="professional-network-organization-card__mission"
                  >{{result.profile.mission}}</p>{{else}}<p
                    class="professional-network-organization-card__mission"
                  >{{result.profile.about}}</p>{{/if}}
              </div>
              {{#if result.badges.length}}
                <div>
                  {{#each result.badges as |badge|}}
                    <span
                      class="professional-network-directory__badge"
                    >{{badge}}</span>
                  {{/each}}
                </div>
              {{/if}}
              <dl>
                {{#if result.profile.sector}}<div><dt>Sector</dt><dd
                    >{{result.profile.sector}}</dd></div>{{/if}}
                {{#if result.profile.stage}}<div><dt>Stage</dt><dd
                    >{{result.profile.stage}}</dd></div>{{/if}}
                {{#if result.profile.city}}<div><dt>Location</dt><dd
                    >{{result.profile.city}}{{#if result.profile.country}},
                        {{result.profile.country}}{{/if}}</dd></div>{{/if}}
              </dl>
              {{#if result.profile.organization_needs.length}}<div><strong
                  >Current needs</strong><div
                    class="professional-network-tags"
                  >{{#each result.profile.organization_needs as |item|}}<span
                      >{{item}}</span>{{/each}}</div></div>{{/if}}
              {{#if result.profile.organization_offerings.length}}<div><strong
                  >Offers</strong><div class="professional-network-tags">{{#each
                      result.profile.organization_offerings
                      as |item|
                    }}<span>{{item}}</span>{{/each}}</div></div>{{/if}}
              {{#if result.profile.organization_opportunities.length}}<div
                ><strong>Opportunities</strong><div
                    class="professional-network-tags"
                  >{{#each
                      result.profile.organization_opportunities
                      as |item|
                    }}<span>{{item}}</span>{{/each}}</div></div>{{/if}}
              {{#if result.profile.collaboration_interests.length}}<div><strong
                  >Looking to collaborate on</strong><div
                    class="professional-network-tags"
                  >{{#each
                      result.profile.collaboration_interests
                      as |item|
                    }}<span>{{item}}</span>{{/each}}</div></div>{{/if}}
              <footer>
                <div>
                  {{#if
                    result.profile.organization_opportunity_details.length
                  }}<span
                    >{{result.profile.organization_opportunity_details.length}}
                      open opportunit{{if
                        (eq
                          result.profile.organization_opportunity_details.length
                          1
                        )
                        "y"
                        "ies"
                      }}</span>{{/if}}
                  {{#if result.profile.organization_projects.length}}<span
                    >{{result.profile.organization_projects.length}}
                      project{{if
                        (eq result.profile.organization_projects.length 1)
                        ""
                        "s"
                      }}</span>{{/if}}
                </div>
                <a
                  class="btn btn-default"
                  href="/u/{{result.username}}/professional-profile"
                >View profile</a>
              </footer>
            </article>
          {{else}}
            <p>No organizations match these filters.</p>
          {{/each}}
        </div>
      {{/if}}
    </div>
  </template>
}
