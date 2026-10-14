import { fn } from "@ember/helper";
import { on } from "@ember/modifier";

const ProfessionalNetworkEditorLinkedinCareer = <template>
  <fieldset
    class="professional-network-aspirations professional-network-review"
  >
    <legend>Experience & education</legend>
    <details
      class="professional-network-form-section"
      open={{@editor.sectionsExpanded}}
    >
      <summary><span>Experience</span><small>{{@editor.experienceCount}}
          entries</small></summary>
      <div
        class="professional-network-services professional-network-form-section__body"
      >
        {{#each @editor.profileData.experience as |job index|}}
          <details class="professional-network-entry">
            <summary>{{if job.title job.title "Experience entry"}}{{#if
                job.organization
              }} · {{job.organization}}{{/if}}</summary>
            <div class="professional-network-service-row">
              <label>Job title<input
                  type="text"
                  value={{job.title}}
                  {{on
                    "input"
                    (fn @editor.changeEntry "experience" index "title")
                  }}
                /></label>
              <label>Organization<input
                  type="text"
                  value={{job.organization}}
                  {{on
                    "input"
                    (fn @editor.changeEntry "experience" index "organization")
                  }}
                /></label>
              <label>Location<input
                  type="text"
                  value={{job.location}}
                  {{on
                    "input"
                    (fn @editor.changeEntry "experience" index "location")
                  }}
                /></label>
              <label>Start year<input
                  max="2100"
                  min="1950"
                  type="number"
                  value={{job.start_year}}
                  {{on
                    "input"
                    (fn @editor.changeEntry "experience" index "start_year")
                  }}
                /></label>
              <label>End year<input
                  disabled={{job.is_current}}
                  max="2100"
                  min="1950"
                  type="number"
                  value={{job.end_year}}
                  {{on
                    "input"
                    (fn @editor.changeEntry "experience" index "end_year")
                  }}
                /></label>
              <label><input
                  checked={{job.is_current}}
                  type="checkbox"
                  {{on
                    "change"
                    (fn @editor.changeEntry "experience" index "is_current")
                  }}
                />
                Current role</label>
              <label class="is-wide">Description<textarea
                  rows="3"
                  value={{job.description}}
                  {{on
                    "input"
                    (fn @editor.changeEntry "experience" index "description")
                  }}
                ></textarea></label>
              <button
                class="btn btn-flat"
                type="button"
                {{on "click" (fn @editor.removeEntry "experience" index)}}
              >Remove</button>
            </div>
          </details>
        {{else}}
          <p>No experience added.</p>
        {{/each}}
        <button
          class="btn btn-default"
          type="button"
          {{on "click" (fn @editor.addEntry "experience")}}
        >+ Add experience</button>
      </div>
    </details>

    <details
      class="professional-network-form-section"
      open={{@editor.sectionsExpanded}}
    >
      <summary><span>Education</span><small>{{@editor.educationCount}}
          entries</small></summary>
      <div
        class="professional-network-services professional-network-form-section__body"
      >
        {{#each @editor.profileData.education as |school index|}}
          <details class="professional-network-entry">
            <summary>{{if school.school school.school "Education entry"}}{{#if
                school.degree
              }} · {{school.degree}}{{/if}}</summary>
            <div class="professional-network-service-row">
              <label>School or university<input
                  type="text"
                  value={{school.school}}
                  {{on
                    "input"
                    (fn @editor.changeEntry "education" index "school")
                  }}
                /></label>
              <label>Degree<input
                  type="text"
                  value={{school.degree}}
                  {{on
                    "input"
                    (fn @editor.changeEntry "education" index "degree")
                  }}
                /></label>
              <label>Field of study<input
                  type="text"
                  value={{school.field}}
                  {{on
                    "input"
                    (fn @editor.changeEntry "education" index "field")
                  }}
                /></label>
              <label>Start year<input
                  max="2100"
                  min="1950"
                  type="number"
                  value={{school.start_year}}
                  {{on
                    "input"
                    (fn @editor.changeEntry "education" index "start_year")
                  }}
                /></label>
              <label>End year<input
                  max="2100"
                  min="1950"
                  type="number"
                  value={{school.end_year}}
                  {{on
                    "input"
                    (fn @editor.changeEntry "education" index "end_year")
                  }}
                /></label>
              <button
                class="btn btn-flat"
                type="button"
                {{on "click" (fn @editor.removeEntry "education" index)}}
              >Remove</button>
            </div>
          </details>
        {{else}}
          <p>No education added.</p>
        {{/each}}
        <button
          class="btn btn-default"
          type="button"
          {{on "click" (fn @editor.addEntry "education")}}
        >+ Add education</button>
      </div>
    </details>

    <details
      class="professional-network-form-section"
      open={{@editor.sectionsExpanded}}
    >
      <summary><span>Certifications</span><small>Imported from LinkedIn</small></summary>
      <div class="professional-network-form-section__body">
        <div class="professional-network-field is-wide">
          <label
            for="professional-network-certifications"
          >Certifications</label>
          <input
            id="professional-network-certifications"
            placeholder="AWS Certified Developer; PMP"
            type="text"
            value={{@editor.certificationsInput}}
            {{on "input" (fn @editor.changeListField "certifications")}}
          />
          <small>Separate multiple certifications with semicolons (;).</small>
        </div>
      </div>
    </details>
  </fieldset>
</template>;

export default ProfessionalNetworkEditorLinkedinCareer;
