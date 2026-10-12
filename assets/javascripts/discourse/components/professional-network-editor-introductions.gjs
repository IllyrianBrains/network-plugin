import { fn } from "@ember/helper";
import { on } from "@ember/modifier";
import { eq } from "discourse/truth-helpers";
import {
  CONTACT_OPTIONS,
  MEETING_OPTIONS,
} from "discourse/plugins/discourse-professional-network/discourse/lib/professional-network-options";

const ProfessionalNetworkEditorIntroductions = <template>
  <fieldset
    class="professional-network-aspirations professional-network-review"
  >
    <legend>Introduction preferences</legend>
    <p>Help the network understand who would be useful for you to meet and how
      you can help others.</p>

    <details class="professional-network-form-section">
      <summary><span>Role & industry</span><small>What you do, in short</small></summary>
      <div class="professional-network-form-section__body">
        <div class="professional-network-field">
          <label for="professional-network-industry">Industry or sector</label>
          <input
            id="professional-network-industry"
            placeholder="e.g. Climate technology"
            type="text"
            value={{@editor.profileData.industry}}
            {{on "input" (fn @editor.changeProfileField "industry")}}
          />
        </div>
        <div class="professional-network-field">
          <label for="professional-network-current-role">Current role</label>
          <input
            id="professional-network-current-role"
            placeholder="e.g. Founder, product designer, student"
            type="text"
            value={{@editor.profileData.current_role}}
            {{on "input" (fn @editor.changeProfileField "current_role")}}
          />
        </div>
      </div>
    </details>

    <details class="professional-network-form-section">
      <summary><span>What you offer and need</span><small>The core of a good
          introduction</small></summary>
      <div class="professional-network-form-section__body">
        <div class="professional-network-field is-wide">
          <label for="professional-network-can-help">What can you help others
            with?</label>
          <textarea
            id="professional-network-can-help"
            placeholder="Topics, introductions, advice, or practical support you can offer"
            rows="4"
            value={{@editor.profileData.can_help_with}}
            {{on "input" (fn @editor.changeProfileField "can_help_with")}}
          ></textarea>
        </div>
        <div class="professional-network-field is-wide">
          <label for="professional-network-looking-for">What are you looking
            for?</label>
          <textarea
            id="professional-network-looking-for"
            placeholder="The opportunity, advice, or connection you need"
            rows="4"
            value={{@editor.profileData.looking_for}}
            {{on "input" (fn @editor.changeProfileField "looking_for")}}
          ></textarea>
        </div>
        <div class="professional-network-field is-wide">
          <label for="professional-network-ideal-connection">Who would be an
            ideal connection?</label>
          <textarea
            id="professional-network-ideal-connection"
            placeholder="Role, expertise, seniority, industry, or organization type"
            rows="3"
            value={{@editor.profileData.ideal_connection}}
            {{on "input" (fn @editor.changeProfileField "ideal_connection")}}
          ></textarea>
        </div>
      </div>
    </details>

    <details class="professional-network-form-section">
      <summary><span>Logistics</span><small>Locations, timing, and how to reach
          you</small></summary>
      <div class="professional-network-form-section__body">
        <div class="professional-network-field is-wide">
          <label for="professional-network-preferred-locations">Preferred
            locations</label>
          <input
            id="professional-network-preferred-locations"
            placeholder="Berlin, Tirana, Remote"
            type="text"
            value={{@editor.preferredLocationsInput}}
            {{on "input" (fn @editor.changeListField "preferred_locations")}}
          />
          <small>Separate multiple locations with commas.</small>
        </div>
        <div class="professional-network-field">
          <label for="professional-network-timing">Availability and timing</label>
          <input
            id="professional-network-timing"
            placeholder="e.g. Available now, from June, casually exploring"
            type="text"
            value={{@editor.profileData.availability_timing}}
            {{on "input" (fn @editor.changeProfileField "availability_timing")}}
          />
        </div>
        <div class="professional-network-field">
          <label for="professional-network-contact-preference">Preferred contact</label>
          <select
            id="professional-network-contact-preference"
            {{on "change" (fn @editor.changeProfileField "contact_preference")}}
          >
            <option
              selected={{eq @editor.profileData.contact_preference undefined}}
              value=""
            >Not specified</option>
            {{#each CONTACT_OPTIONS as |choice|}}<option
                selected={{eq
                  @editor.profileData.contact_preference
                  choice.value
                }}
                value={{choice.value}}
              >{{choice.label}}</option>{{/each}}
          </select>
        </div>
        <div class="professional-network-field">
          <label for="professional-network-meeting-preference">Preferred meeting
            format</label>
          <select
            id="professional-network-meeting-preference"
            {{on "change" (fn @editor.changeProfileField "meeting_preference")}}
          >
            <option
              selected={{eq @editor.profileData.meeting_preference undefined}}
              value=""
            >Not specified</option>
            {{#each MEETING_OPTIONS as |choice|}}<option
                selected={{eq
                  @editor.profileData.meeting_preference
                  choice.value
                }}
                value={{choice.value}}
              >{{choice.label}}</option>{{/each}}
          </select>
        </div>
        <div class="professional-network-field is-wide">
          <label class="professional-network-chip"><input
              checked={{@editor.profileData.open_to_introductions}}
              type="checkbox"
              {{on
                "change"
                (fn @editor.changeProfileCheckbox "open_to_introductions")
              }}
            />Open to introductions from other members</label>
        </div>
      </div>
    </details>
  </fieldset>
</template>;

export default ProfessionalNetworkEditorIntroductions;
