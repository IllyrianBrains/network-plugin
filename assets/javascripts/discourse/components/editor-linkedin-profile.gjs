import { fn } from "@ember/helper";
import { on } from "@ember/modifier";

const ProfessionalNetworkEditorLinkedinProfile = <template>
  <fieldset
    class="professional-network-aspirations professional-network-review"
  >
    <legend>Profile</legend>

    <details
      class="professional-network-form-section"
      open={{@editor.sectionsExpanded}}
    >
      <summary><span>Basic information</span></summary>
      <div class="professional-network-form-section__body">
        <div class="professional-network-field is-wide">
          <label for="professional-network-name">Full name</label>
          <input
            id="professional-network-name"
            maxlength="160"
            placeholder="Your full name"
            type="text"
            value={{@editor.profileData.name}}
            {{on "input" (fn @editor.changeProfileField "name")}}
          />
        </div>
        <div class="professional-network-field is-wide">
          <label for="professional-network-headline">Professional headline</label>
          <input
            id="professional-network-headline"
            maxlength="300"
            placeholder="e.g. Product designer helping early-stage teams"
            type="text"
            value={{@editor.profileData.headline}}
            {{on "input" (fn @editor.changeProfileField "headline")}}
          />
        </div>
        <div class="professional-network-field is-wide">
          <label for="professional-network-company">Current organization</label>
          <input
            id="professional-network-company"
            maxlength="160"
            placeholder="Company, university, or independent"
            type="text"
            value={{@editor.profileData.company}}
            {{on "input" (fn @editor.changeProfileField "company")}}
          />
        </div>
        <div class="professional-network-field-group is-wide">
          <span class="professional-network-field-group__label">Location</span>
          <div class="professional-network-field-group__row">
            <div class="professional-network-field">
              <label for="professional-network-city">City</label>
              <input
                id="professional-network-city"
                maxlength="120"
                placeholder="Berlin"
                type="text"
                value={{@editor.profileData.city}}
                {{on "input" (fn @editor.changeProfileField "city")}}
              />
            </div>
            <div class="professional-network-field">
              <label for="professional-network-country">Country</label>
              <input
                id="professional-network-country"
                maxlength="120"
                placeholder="Germany"
                type="text"
                value={{@editor.profileData.country}}
                {{on "input" (fn @editor.changeProfileField "country")}}
              />
            </div>
          </div>
        </div>
        <div class="professional-network-field is-wide">
          <label for="professional-network-about">About you</label>
          <textarea
            id="professional-network-about"
            maxlength="5000"
            placeholder="Describe your work, interests, and what you would like other members to know."
            rows="6"
            value={{@editor.profileData.about}}
            {{on "input" (fn @editor.changeProfileField "about")}}
          ></textarea>
        </div>
        <div class="professional-network-field is-wide">
          <label for="professional-network-languages">Languages</label>
          <input
            id="professional-network-languages"
            placeholder="Albanian, English, German"
            type="text"
            value={{@editor.languagesInput}}
            {{on "input" (fn @editor.changeListField "languages")}}
          />
        </div>
      </div>
    </details>

    <details
      class="professional-network-form-section"
      open={{@editor.sectionsExpanded}}
    >
      <summary><span>Expertise & skills</span></summary>
      <div class="professional-network-form-section__body">
        <div class="professional-network-field is-wide">
          <label for="professional-network-expertise">Fields of expertise</label>
          <input
            id="professional-network-expertise"
            placeholder="Technology, Finance, Healthcare"
            type="text"
            value={{@editor.fieldsOfExpertiseInput}}
            {{on "input" (fn @editor.changeListField "fields_of_expertise")}}
          />
        </div>
        <div class="professional-network-field is-wide">
          <label for="professional-network-skills">Specific skills</label>
          <input
            id="professional-network-skills"
            placeholder="Ruby, Project management, Fundraising"
            type="text"
            value={{@editor.skillsInput}}
            {{on "input" (fn @editor.changeListField "skills")}}
          />
        </div>
      </div>
    </details>

  </fieldset>
</template>;

export default ProfessionalNetworkEditorLinkedinProfile;
