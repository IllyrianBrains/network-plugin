import Component from "@glimmer/component";
import { tracked } from "@glimmer/tracking";
import { fn } from "@ember/helper";
import { action } from "@ember/object";
import { service } from "@ember/service";
import { modifier } from "ember-modifier";
import { ajax } from "discourse/lib/ajax";
import { not, or } from "discourse/truth-helpers";
import dIcon from "discourse/ui-kit/helpers/d-icon";

export default class ProfessionalNetworkRecommendations extends Component {
  @service siteSettings;

  @tracked loading = true;
  @tracked error = false;
  @tracked profileReady = false;
  @tracked recommendations = [];
  @tracked hiddenRecommendations = [];
  @tracked showingHidden = false;

  load = modifier(() => this.loadRecommendations());

  @action
  async markHelpful(result) {
    await this.saveFeedback(result, { helpful: !result.feedback?.helpful });
  }

  @action
  async hide(result) {
    await this.saveFeedback(result, { hidden: true });
    this.recommendations = this.recommendations.filter(
      (item) => item.username !== result.username
    );
  }

  @action
  async toggleHidden() {
    this.showingHidden = !this.showingHidden;
    if (!this.showingHidden) {
      return;
    }
    try {
      const response = await ajax("/network/recommendations/hidden");
      this.hiddenRecommendations = response.profiles || [];
    } catch {
      this.error = true;
    }
  }

  @action
  async restore(result) {
    await this.saveFeedback(result, { hidden: false });
    this.hiddenRecommendations = this.hiddenRecommendations.filter(
      (item) => item.username !== result.username
    );
    await this.loadRecommendations();
  }

  @action
  async requestIntroduction(result) {
    try {
      const response = await ajax(
        `/network/recommendations/${result.username}/introduction`,
        { type: "POST" }
      );
      window.location.assign(`/t/${response.topic_id}`);
    } catch {
      this.error = true;
    }
  }

  async saveFeedback(result, feedback) {
    const response = await ajax(
      `/network/recommendations/${result.username}/feedback`,
      { type: "PUT", data: { feedback } }
    );
    result.feedback = response;
    this.recommendations = [...this.recommendations];
  }

  @action
  refresh() {
    this.loadRecommendations();
  }

  async loadRecommendations() {
    this.loading = true;
    this.error = false;
    try {
      const response = await ajax("/network/recommendation-results");
      this.profileReady = response.profile_ready;
      this.recommendations = response.profiles || [];
    } catch {
      this.error = true;
    } finally {
      this.loading = false;
    }
  }

  <template>
    <div class="professional-network-recommendations" {{this.load}}>
      <header>
        <p class="professional-network-panel__eyebrow">{{this.siteSettings.professional_network_name}}</p>
        <h2>Connections</h2>
        <p>Recommendations based on shared interests, relevant expertise, and
          ways you may be able to help one another.</p>
        <div class="professional-network-recommendations__header-actions">
          <button
            class="btn btn-default"
            type="button"
            {{on "click" this.refresh}}
          >Refresh recommendations</button>
          <button
            class="btn btn-flat"
            type="button"
            {{on "click" this.toggleHidden}}
          >{{if this.showingHidden "Hide hidden people" "Manage hidden people"}}</button>
        </div>
      </header>

      {{#if this.showingHidden}}
        <section class="professional-network-recommendations__hidden">
          <h3>Hidden people</h3>
          {{#each this.hiddenRecommendations as |result|}}
            <div>
              <a href="/u/{{result.username}}/professional-profile">{{or
                  result.profile.name
                  result.username
                }}</a>
              <button
                class="btn btn-flat"
                type="button"
                {{on "click" (fn this.restore result)}}
              >Show in recommendations again</button>
            </div>
          {{else}}
            <p>You have no hidden recommendations.</p>
          {{/each}}
        </section>
      {{/if}}

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
              <div class="professional-network-recommendation-card__actions">
                {{#if result.profile.open_to_introductions}}
                  <button
                    class="btn btn-primary"
                    type="button"
                    {{on "click" (fn this.requestIntroduction result)}}
                  >Request introduction</button>
                {{/if}}
                <button
                  class="btn btn-flat"
                  type="button"
                  {{on "click" (fn this.markHelpful result)}}
                >{{if
                    result.feedback.helpful
                    "Marked helpful"
                    "Helpful"
                  }}</button>
                <button
                  class="btn btn-flat"
                  type="button"
                  {{on "click" (fn this.hide result)}}
                >Hide</button>
              </div>
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
