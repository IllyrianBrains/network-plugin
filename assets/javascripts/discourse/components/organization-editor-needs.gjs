import { fn } from "@ember/helper";
import { on } from "@ember/modifier";

const OrganizationNeeds = <template>
  <fieldset
    class="professional-network-aspirations professional-network-review"
  >
    <legend>Needs & collaboration</legend><p>Help members see where
      introductions or practical support would be useful.</p>
    <details class="professional-network-form-section" open><summary><span
        >Current needs</span><small>What would help right now</small></summary><div
        class="professional-network-form-section__body"
      ><div class="professional-network-field is-wide"><label
            for="professional-network-organization-needs"
          >What does the organization need?</label><input
            id="professional-network-organization-needs"
            placeholder="Hiring, funding, distribution partners, legal expertise"
            type="text"
            value={{@editor.organizationNeedsInput}}
            {{on
              "input"
              (fn @editor.changeOrganizationList "organization_needs")
            }}
          /><small>Separate items with commas.</small></div></div></details>
    <details class="professional-network-form-section"><summary><span
        >Collaboration interests</span></summary><div
        class="professional-network-form-section__body"
      ><div class="professional-network-field is-wide"><label
            for="professional-network-organization-collaboration"
          >Ways you want to collaborate</label><input
            id="professional-network-organization-collaboration"
            placeholder="Research, co-marketing, investment, community projects"
            type="text"
            value={{@editor.collaborationInterestsInput}}
            {{on
              "input"
              (fn @editor.changeOrganizationList "collaboration_interests")
            }}
          /><small>Separate items with commas.</small></div></div></details>
  </fieldset>
</template>;

export default OrganizationNeeds;
