import { fn } from "@ember/helper";
import { on } from "@ember/modifier";
import { eq } from "discourse/truth-helpers";
import { ORGANIZATION_TYPE_OPTIONS } from "discourse/plugins/discourse-professional-network/discourse/lib/options";

const OrganizationOverview = <template>
  <fieldset
    class="professional-network-aspirations professional-network-review"
  >
    <legend>Overview</legend><p>Introduce the organization and help members
      understand its work.</p>
    <details class="professional-network-form-section" open><summary><span
        >Identity</span><small>Type, sector, and stage</small></summary><div
        class="professional-network-form-section__body"
      >
        <div class="professional-network-field is-wide"><label
            for="professional-network-organization-name"
          >Name</label><input
            id="professional-network-organization-name"
            placeholder="e.g. Illyrian Brains Network"
            type="text"
            value={{@editor.profileData.name}}
            {{on "input" (fn @editor.changeProfileField "name")}}
          /></div>
        <div class="professional-network-field"><label
            for="professional-network-organization-type"
          >Organization type</label><select
            id="professional-network-organization-type"
            {{on "change" (fn @editor.changeProfileField "organization_type")}}
          >
            <option
              selected={{eq @editor.profileData.organization_type undefined}}
              value=""
            >Select a type</option>
            {{#each ORGANIZATION_TYPE_OPTIONS as |choice|}}
              <option
                selected={{eq
                  @editor.profileData.organization_type
                  choice.value
                }}
                value={{choice.value}}
              >{{choice.label}}</option>
            {{/each}}
          </select><small>Choose “Professional network” for organizations such
            as Illyrian Brains Network.</small></div>
        {{#if (eq @editor.profileData.organization_type "other")}}
          <div class="professional-network-field"><label
              for="professional-network-organization-type-other"
            >Other organization type</label><input
              id="professional-network-organization-type-other"
              placeholder="Describe the organization type"
              type="text"
              value={{@editor.profileData.organization_type_other}}
              {{on
                "input"
                (fn @editor.changeProfileField "organization_type_other")
              }}
            /></div>
        {{/if}}
        <div class="professional-network-field"><label
            for="professional-network-organization-sector"
          >Sector</label><input
            id="professional-network-organization-sector"
            placeholder="Technology, education, healthcare…"
            type="text"
            value={{@editor.profileData.sector}}
            {{on "input" (fn @editor.changeProfileField "sector")}}
          /></div>
        <div class="professional-network-field"><label
            for="professional-network-organization-stage"
          >Stage</label><input
            id="professional-network-organization-stage"
            placeholder="Idea, startup, growing, established…"
            type="text"
            value={{@editor.profileData.stage}}
            {{on "input" (fn @editor.changeProfileField "stage")}}
          /></div>
      </div></details>
    <details class="professional-network-form-section"><summary><span
        >Locations</span><small>Where you operate</small></summary><div
        class="professional-network-form-section__body"
      >
        <div class="professional-network-field"><label
            for="professional-network-organization-city"
          >Primary city</label><input
            id="professional-network-organization-city"
            type="text"
            value={{@editor.profileData.city}}
            {{on "input" (fn @editor.changeProfileField "city")}}
          /></div>
        <div class="professional-network-field"><label
            for="professional-network-organization-country"
          >Country</label><input
            id="professional-network-organization-country"
            type="text"
            value={{@editor.profileData.country}}
            {{on "input" (fn @editor.changeProfileField "country")}}
          /></div>
        <div class="professional-network-field is-wide"><label
            for="professional-network-organization-locations"
          >Other locations</label><input
            id="professional-network-organization-locations"
            placeholder="Prishtina, Berlin, London"
            type="text"
            value={{@editor.organizationLocationsInput}}
            {{on
              "input"
              (fn @editor.changeOrganizationList "organization_locations")
            }}
          /><small>Separate multiple locations with commas.</small></div>
      </div></details>
    <details class="professional-network-form-section"><summary><span>Mission &
          description</span></summary><div
        class="professional-network-form-section__body"
      >
        <div class="professional-network-field is-wide"><label
            for="professional-network-organization-mission"
          >Mission</label><textarea
            id="professional-network-organization-mission"
            rows="3"
            value={{@editor.profileData.mission}}
            {{on "input" (fn @editor.changeProfileField "mission")}}
          ></textarea></div>
        <div class="professional-network-field is-wide"><label
            for="professional-network-organization-about"
          >Description</label><textarea
            id="professional-network-organization-about"
            rows="6"
            value={{@editor.profileData.about}}
            {{on "input" (fn @editor.changeProfileField "about")}}
          ></textarea></div>
      </div></details>
  </fieldset>
</template>;

export default OrganizationOverview;
