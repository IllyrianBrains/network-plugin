import { on } from "@ember/modifier";
import { and, eq, or } from "discourse/truth-helpers";

const ProfessionalNetworkPanelHeader = <template>
  <div class="professional-network-panel__header">
    {{#if @panel.profile.logo_url}}<img
        alt=""
        class="professional-network-panel__logo"
        src={{@panel.profile.logo_url}}
      />{{/if}}
    <div>
      <p class="professional-network-panel__eyebrow">Professional profile</p>
      <div class="professional-network-profile-trust">
        {{#if @panel.verifiedAt}}<span>Verified organization</span>{{/if}}
        {{#if @panel.stale}}<span class="is-stale">May need updating</span>{{/if}}
      </div>
      <h2>{{if
          (eq @panel.profileType "organization")
          @panel.profile.name
          @panel.profile.headline
        }}{{#if @panel.profile.pronouns}}
          <small>({{@panel.profile.pronouns}})</small>{{/if}}</h2>
      {{#if (or @panel.profile.current_role @panel.profile.company)}}
        <p>{{@panel.profile.current_role}}{{#if
            (and @panel.profile.current_role @panel.profile.company)
          }}
            ·
          {{/if}}{{@panel.profile.company}}</p>
      {{/if}}
      {{#if (or @panel.profile.city @panel.profile.country)}}
        <p>{{@panel.profile.city}}{{#if
            (and @panel.profile.city @panel.profile.country)
          }}, {{/if}}{{@panel.profile.country}}</p>
      {{else if @panel.profile.location}}
        <p>{{@panel.profile.location}}</p>
      {{/if}}
      {{#if @panel.profile.about}}<p
          class="professional-network-panel__about"
        >{{@panel.profile.about}}</p>{{/if}}
      {{#if @panel.experienceLevelLabel}}<div
          class="professional-network-tags"
        ><span>{{@panel.experienceLevelLabel}}</span></div>{{/if}}
      {{#if
        (or
          @panel.profile.open_to_work
          @panel.profile.hiring
          @panel.profile.open_to_collaboration
          @panel.profile.open_to_speaking
          @panel.profile.open_to_volunteering
          @panel.profile.open_to_relocation
        )
      }}
        <div class="professional-network-tags">
          {{#if @panel.profile.open_to_work}}<span>Open to work</span>{{/if}}
          {{#if @panel.profile.hiring}}<span>Hiring</span>{{/if}}
          {{#if @panel.profile.open_to_collaboration}}<span>Open to
              collaboration</span>{{/if}}
          {{#if @panel.profile.open_to_speaking}}<span>Available for speaking</span>{{/if}}
          {{#if @panel.profile.open_to_volunteering}}<span>Open to volunteering</span>{{/if}}
          {{#if @panel.profile.open_to_relocation}}<span>Open to relocation</span>{{/if}}
        </div>
      {{/if}}
      {{#if (or @panel.availabilityLabel @panel.profile.open_to_consulting)}}
        <div class="professional-network-tags">
          {{#if @panel.availabilityLabel}}<span
            >{{@panel.availabilityLabel}}</span>{{/if}}
          {{#if @panel.profile.open_to_consulting}}<span>Open to consulting</span>{{/if}}
        </div>
      {{/if}}
      {{#if
        (or @panel.profile.freelance_rate @panel.profile.minimum_project_size)
      }}
        <p>
          {{#if @panel.profile.freelance_rate}}Pricing:
            {{@panel.profile.freelance_rate}}{{/if}}
          {{#if
            (and
              @panel.profile.freelance_rate @panel.profile.minimum_project_size
            )
          }} · {{/if}}
          {{#if @panel.profile.minimum_project_size}}Minimum engagement:
            {{@panel.profile.minimum_project_size}}{{/if}}
        </p>
      {{/if}}
    </div>
    <div class="professional-network-panel__links">
      {{#if @panel.isOwnProfile}}<button
          class="btn btn-default"
          type="button"
          {{on "click" @panel.togglePrivacyPreview}}
        >{{if
            @panel.privacyPreview
            "Exit public preview"
            "Preview as public"
          }}</button>{{/if}}
      {{#if @panel.isOwnProfile}}<a
          class="btn btn-primary"
          href="/network/profile"
        >Edit profile</a>{{/if}}
      {{#if @panel.canAdminEdit}}<a
          class="btn btn-default"
          href="/network/profile/{{@panel.username}}"
        >Edit profile (admin)</a>{{/if}}
      {{#if @panel.canVerifyOrganization}}<button
          class="btn btn-default"
          type="button"
          {{on "click" @panel.verifyOrganization}}
        >Verify organization</button>{{/if}}
      {{#if @panel.profile.linkedin_url}}<a
          class="btn btn-default professional-network-linkedin-link"
          href={{@panel.profile.linkedin_url}}
          rel="noopener noreferrer"
          target="_blank"
        >LinkedIn</a>{{/if}}
      {{#each @panel.organizationProfiles as |organization|}}<a
          class="btn btn-default"
          href={{organization.url}}
        >{{organization.username}}</a>{{/each}}
      {{#if @panel.profile.website}}<a
          class="btn btn-default"
          href={{@panel.profile.website}}
          rel="noopener noreferrer"
          target="_blank"
        >Website</a>{{/if}}
      {{#if @panel.profile.github_url}}<a
          class="btn btn-default"
          href={{@panel.profile.github_url}}
          rel="noopener noreferrer"
          target="_blank"
        >GitHub</a>{{/if}}
      {{#if @panel.profile.twitter_url}}<a
          class="btn btn-default"
          href={{@panel.profile.twitter_url}}
          rel="noopener noreferrer"
          target="_blank"
        >X / Twitter</a>{{/if}}
      {{#if @panel.profile.portfolio_url}}<a
          class="btn btn-default"
          href={{@panel.profile.portfolio_url}}
          rel="noopener noreferrer"
          target="_blank"
        >Portfolio</a>{{/if}}
      {{#if @panel.profile.calendar_url}}<a
          class="btn btn-default"
          href={{@panel.profile.calendar_url}}
          rel="noopener noreferrer"
          target="_blank"
        >Book a meeting</a>{{/if}}
      {{#if @panel.profile.contact_url}}<a
          class="btn btn-default"
          href={{@panel.profile.contact_url}}
          rel="noopener noreferrer"
          target="_blank"
        >Contact</a>{{/if}}
      {{#if @panel.profile.instagram_url}}<a
          class="btn btn-default"
          href={{@panel.profile.instagram_url}}
          rel="noopener noreferrer"
          target="_blank"
        >Instagram</a>{{/if}}
    </div>
  </div>
</template>;

export default ProfessionalNetworkPanelHeader;
