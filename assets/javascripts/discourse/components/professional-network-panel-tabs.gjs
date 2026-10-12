import { concat } from "@ember/helper";
import { eq, or } from "discourse/truth-helpers";

const ProfessionalNetworkPanelTabs = <template>
  <div class="professional-network-panel__sections">
    <details class="professional-network-form-section">
      <summary><span>Introductions</span></summary>
      <div class="professional-network-list">
        {{#if @panel.hasIntroductions}}
          {{#if (or @panel.profile.industry @panel.profile.current_role)}}
            <article>
              <h3>{{or @panel.profile.current_role "Current role"}}</h3>
              {{#if @panel.profile.industry}}<p
                >{{@panel.profile.industry}}</p>{{/if}}
            </article>
          {{/if}}
          {{#if @panel.profile.can_help_with}}<article><h3>Can help with</h3><p
              >{{@panel.profile.can_help_with}}</p></article>{{/if}}
          {{#if @panel.profile.looking_for}}<article><h3>Looking for</h3><p
              >{{@panel.profile.looking_for}}</p></article>{{/if}}
          {{#if @panel.profile.ideal_connection}}<article><h3>Ideal connection</h3><p
              >{{@panel.profile.ideal_connection}}</p></article>{{/if}}
          {{#if @panel.preferredLocations.length}}<article><h3>Preferred
                locations</h3><div class="professional-network-tags">{{#each
                  @panel.preferredLocations
                  as |location|
                }}<span>{{location}}</span>{{/each}}</div></article>{{/if}}
          {{#if @panel.profile.availability_timing}}<article><h3>Availability &
                timing</h3><p
              >{{@panel.profile.availability_timing}}</p></article>{{/if}}
          {{#if
            (or @panel.contactPreferenceLabel @panel.meetingPreferenceLabel)
          }}
            <article>
              <h3>How to reach out</h3>
              {{#if @panel.contactPreferenceLabel}}<p>Preferred contact:
                  {{@panel.contactPreferenceLabel}}</p>{{/if}}
              {{#if @panel.meetingPreferenceLabel}}<p>Preferred meeting format:
                  {{@panel.meetingPreferenceLabel}}</p>{{/if}}
            </article>
          {{/if}}
          {{#if @panel.profile.open_to_introductions}}<article><p>Open to
                introductions from other members.</p></article>{{/if}}
        {{else}}
          <p>No introduction preferences added yet.</p>
        {{/if}}
      </div>
    </details>

    <details class="professional-network-form-section">
      <summary><span>Services</span></summary>
      <div class="professional-network-list">{{#each
          @panel.profile.services
          as |offer|
        }}<article><h3>{{offer.title}}</h3>{{#if offer.rate}}<p
              >{{offer.rate}}</p>{{/if}}<p
            >{{offer.description}}</p></article>{{else}}<p>No services added
            yet.</p>{{/each}}</div>
    </details>

    <details class="professional-network-form-section">
      <summary><span>Mentoring</span></summary>
      <div class="professional-network-list">
        {{#if @panel.hasMentoring}}
          {{#if @panel.mentoringInterests.length}}<article><h3>Mentoring
                preferences</h3><div class="professional-network-tags">{{#each
                  @panel.mentoringInterests
                  as |interest|
                }}<span>{{interest}}</span>{{/each}}</div></article>{{/if}}
          {{#if @panel.mentoringWantedTypes.length}}<article><h3>Mentoring
                wanted</h3><div class="professional-network-tags">{{#each
                  @panel.mentoringWantedTypes
                  as |type|
                }}<span>{{type}}</span>{{/each}}</div></article>{{/if}}
          {{#if @panel.mentoringProvidedTypes.length}}<article><h3>Mentoring
                provided</h3><div class="professional-network-tags">{{#each
                  @panel.mentoringProvidedTypes
                  as |type|
                }}<span>{{type}}</span>{{/each}}</div></article>{{/if}}
          {{#if @panel.aspirations.mentoring_note}}<article><h3>Mentoring
                details</h3><p
              >{{@panel.aspirations.mentoring_note}}</p></article>{{/if}}
        {{else}}
          <p>No mentoring preferences added yet.</p>
        {{/if}}
      </div>
    </details>

    <details class="professional-network-form-section">
      <summary><span>Next step</span></summary>
      <div class="professional-network-list">
        {{#if @panel.hasAspirations}}
          {{#if @panel.aspirations.field}}<article><h3
              >{{@panel.aspirations.field}}</h3>{{#if
                @panel.aspirations.subfield
              }}<p>{{@panel.aspirations.subfield}}</p>{{/if}}</article>{{/if}}
          {{#if @panel.businessInterests.length}}<article><h3
              >Networking</h3><div class="professional-network-tags">{{#each
                  @panel.businessInterests
                  as |interest|
                }}<span>{{interest}}</span>{{/each}}</div></article>{{/if}}
          {{#if @panel.aspirations.note}}<article><h3>What's next</h3><p
              >{{@panel.aspirations.note}}</p></article>{{/if}}
        {{else}}
          <p>No next step added yet.</p>
        {{/if}}
      </div>
    </details>

    <details class="professional-network-form-section">
      <summary><span>Posts</span></summary>
      <div class="professional-network-list">{{#each
          @panel.activity
          as |item|
        }}<article><small>{{if
                (eq item.kind "linkedin_share")
                "Shared from LinkedIn"
                "Discourse discussion"
              }}</small><h3><a
                href={{concat "/t/" item.slug "/" item.topic_id}}
              >{{item.title}}</a></h3>{{#if item.source_url}}<a
                href={{item.source_url}}
                rel="noopener noreferrer"
                target="_blank"
              >Original LinkedIn post</a>{{/if}}</article>{{else}}<p>No visible
            posts yet.</p>{{/each}}</div>
    </details>
  </div>
</template>;

export default ProfessionalNetworkPanelTabs;
