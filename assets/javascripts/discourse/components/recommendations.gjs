import Component from "@glimmer/component";
import { tracked } from "@glimmer/tracking";
import { service } from "@ember/service";
import { modifier } from "ember-modifier";
import { ajax } from "discourse/lib/ajax";
import { not, or } from "discourse/truth-helpers";
import dIcon from "discourse/ui-kit/helpers/d-icon";

export default class ProfessionalNetworkRecommendations extends Component {
  @service currentUser;

  @tracked loading = true;
  @tracked error = false;
  @tracked profileReady = false;
  @tracked recommendations = [];

  load = modifier(async () => {
    if (!this.currentUser) {
      this.loading = false;
      return;
    }

    try {
      const response = await ajax("/network/recommendation-results");
      this.profileReady = response.profile_ready;
      this.recommendations = response.profiles || [];
    } catch {
      this.error = true;
    } finally {
      this.loading = false;
    }
  });

  <template>
    <div class="professional-network-recommendations" {{this.load}}>
      <header>
        <p class="professional-network-panel__eyebrow">Professional network</p>
        <h2>Connections</h2>
        <p>Recommendations based on shared interests, relevant expertise, and
          ways you may be able to help one another.</p>
      </header>

      {{#if this.loading}}
        <div class="professional-network-recommendations__placeholder">
          {{dIcon "spinner" class="fa-spin"}}
          <p>Finding people for you…</p>
        </div>
      {{else if this.error}}
        <div class="professional-network-recommendations__placeholder">
          {{dIcon "triangle-exclamation"}}
          <p>Could not load your recommendations.</p>
        </div>
      {{else if (not this.currentUser)}}
        <div class="professional-network-recommendations__placeholder">
          <p>Log in to see personalized recommendations.</p>
          <a class="btn btn-primary" href="/login">Log in</a>
        </div>
      {{else if (not this.profileReady)}}
        <div class="professional-network-recommendations__placeholder">
          <p>Complete your professional profile to get recommendations.</p>
          <a class="btn btn-primary" href="/network/profile">Create my profile</a>
        </div>
      {{else}}
        <div class="professional-network-recommendations__grid">
          {{#each this.recommendations as |result|}}
            <article class="professional-network-recommendation-card">
              <div class="professional-network-recommendation-card__person">
                {{#if result.avatar_url}}
                  <img alt="" src={{result.avatar_url}} />
                {{/if}}
                <div>
                  <h3><a href="/u/{{result.username}}/professional-profile">{{or
                        result.profile.name
                        result.username
                      }}</a></h3>
                  {{#if result.profile.headline}}<p
                    >{{result.profile.headline}}</p>{{/if}}
                  {{#if result.profile.company}}<small
                    >{{result.profile.company}}</small>{{/if}}
                </div>
              </div>
              <div class="professional-network-recommendation-card__reasons">
                <strong>Why you should meet</strong>
                <ul>
                  {{#each result.reasons as |reason|}}<li
                    >{{reason}}</li>{{/each}}
                </ul>
              </div>
              <a
                class="btn btn-default"
                href="/u/{{result.username}}/professional-profile"
              >View profile</a>
            </article>
          {{else}}
            <div class="professional-network-recommendations__placeholder">
              <p>No strong matches yet. Add more expertise, skills, and what you
                are looking for to improve your recommendations.</p>
              <a class="btn btn-primary" href="/network/profile">Improve my
                profile</a>
            </div>
          {{/each}}
        </div>
      {{/if}}
    </div>
  </template>
}
