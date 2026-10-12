import { on } from "@ember/modifier";
import { eq } from "discourse/truth-helpers";
import { EXPERIENCE_LEVEL_OPTIONS } from "discourse/plugins/discourse-professional-network/discourse/lib/professional-network-options";

const ProfessionalNetworkEditorStatus = <template>
  <fieldset
    class="professional-network-aspirations professional-network-review"
  >
    <legend>Status</legend>

    <details class="professional-network-form-section">
      <summary><span>Status</span><small>Shown on your public profile</small></summary>
      <div class="professional-network-form-section__body">
        <div class="professional-network-field is-wide">
          <div class="professional-network-chips">
            <label class="professional-network-chip">
              <input
                checked={{@editor.openToWork}}
                type="checkbox"
                {{on "change" @editor.changeOpenToWork}}
              />
              Open to work
            </label>
            <label class="professional-network-chip">
              <input
                checked={{@editor.hiring}}
                type="checkbox"
                {{on "change" @editor.changeHiring}}
              />
              Hiring
            </label>
            <label class="professional-network-chip">
              <input
                checked={{@editor.openToCollaboration}}
                type="checkbox"
                {{on "change" @editor.changeOpenToCollaboration}}
              />
              Open to collaboration
            </label>
            <label class="professional-network-chip">
              <input
                checked={{@editor.openToSpeaking}}
                type="checkbox"
                {{on "change" @editor.changeOpenToSpeaking}}
              />
              Available for speaking
            </label>
            <label class="professional-network-chip">
              <input
                checked={{@editor.openToVolunteering}}
                type="checkbox"
                {{on "change" @editor.changeOpenToVolunteering}}
              />
              Open to volunteering
            </label>
            <label class="professional-network-chip">
              <input
                checked={{@editor.openToRelocation}}
                type="checkbox"
                {{on "change" @editor.changeOpenToRelocation}}
              />
              Open to relocation
            </label>
          </div>
        </div>
      </div>
    </details>

    <details class="professional-network-form-section">
      <summary><span>Personal details</span></summary>
      <div class="professional-network-form-section__body">
        <div class="professional-network-field">
          <label for="professional-network-pronouns">Pronouns</label>
          <input
            id="professional-network-pronouns"
            maxlength="40"
            placeholder="e.g. she/her"
            type="text"
            value={{@editor.pronouns}}
            {{on "input" @editor.changePronouns}}
          />
        </div>
        <div class="professional-network-field">
          <label for="professional-network-experience-level">Professional level</label>
          <select
            id="professional-network-experience-level"
            {{on "change" @editor.changeExperienceLevel}}
          >
            <option selected={{eq @editor.experienceLevel ""}} value="">Not
              specified</option>
            {{#each EXPERIENCE_LEVEL_OPTIONS as |choice|}}
              <option
                selected={{eq @editor.experienceLevel choice.value}}
                value={{choice.value}}
              >{{choice.label}}</option>
            {{/each}}
          </select>
        </div>
        {{#if @editor.timezone}}
          <div class="professional-network-field is-wide">
            <small>Timezone:
              {{@editor.timezone}}
              (set in your
              <a href="/my/preferences/interface">account preferences</a>)</small>
          </div>
        {{/if}}
      </div>
    </details>

    <details class="professional-network-form-section">
      <summary><span>Links</span></summary>
      <div class="professional-network-form-section__body">
        <div class="professional-network-field">
          <label for="professional-network-linkedin">LinkedIn profile</label>
          <input
            id="professional-network-linkedin"
            placeholder="https://www.linkedin.com/in/yourname"
            type="url"
            value={{@editor.linkedinUrl}}
            {{on "input" @editor.changeLinkedinUrl}}
          />
        </div>
        <div class="professional-network-field">
          <label for="professional-network-website">Website</label>
          <input
            id="professional-network-website"
            placeholder="https://example.com"
            type="url"
            value={{@editor.websiteUrl}}
            {{on "input" @editor.changeWebsiteUrl}}
          />
        </div>
        <div class="professional-network-field">
          <label for="professional-network-github">GitHub profile</label>
          <input
            id="professional-network-github"
            placeholder="https://github.com/yourname"
            type="url"
            value={{@editor.githubUrl}}
            {{on "input" @editor.changeGithubUrl}}
          />
        </div>
        <div class="professional-network-field">
          <label for="professional-network-twitter">X / Twitter profile</label>
          <input
            id="professional-network-twitter"
            placeholder="https://x.com/yourname"
            type="url"
            value={{@editor.twitterUrl}}
            {{on "input" @editor.changeTwitterUrl}}
          />
        </div>
        <div class="professional-network-field">
          <label for="professional-network-portfolio">Portfolio or work samples</label>
          <input
            id="professional-network-portfolio"
            placeholder="https://portfolio.example.com"
            type="url"
            value={{@editor.portfolioUrl}}
            {{on "input" @editor.changePortfolioUrl}}
          />
        </div>
        <div class="professional-network-field">
          <label for="professional-network-calendar">Booking link</label>
          <input
            id="professional-network-calendar"
            placeholder="https://cal.example.com/yourname"
            type="url"
            value={{@editor.calendarUrl}}
            {{on "input" @editor.changeCalendarUrl}}
          />
          <small>Only add this if you want it visible on your public profile.</small>
        </div>
      </div>
    </details>
  </fieldset>
</template>;

export default ProfessionalNetworkEditorStatus;
