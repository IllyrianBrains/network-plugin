import { tracked } from "@glimmer/tracking";
import { action } from "@ember/object";
import ProfessionalNetworkEditorProfileState from "discourse/plugins/discourse-professional-network/discourse/lib/editor-profile-state";

// Comma-separated list fields edited as raw strings (like
// fieldsOfExpertiseInput etc. on the base class), so a trailing comma typed
// mid-edit isn't immediately parsed away before the member can type the
// next item.
export const ORGANIZATION_LIST_INPUT_FIELDS = {
  organization_offerings: "organizationOfferingsInput",
  organization_opportunities: "organizationOpportunitiesInput",
  organization_needs: "organizationNeedsInput",
  collaboration_interests: "collaborationInterestsInput",
  organization_locations: "organizationLocationsInput",
};

export default class ProfessionalNetworkEditorOrganizationState extends ProfessionalNetworkEditorProfileState {
  @tracked organizationOfferingsInput = "";
  @tracked organizationOpportunitiesInput = "";
  @tracked organizationNeedsInput = "";
  @tracked collaborationInterestsInput = "";
  @tracked organizationLocationsInput = "";

  splitStatusFields(profile) {
    const rest = super.splitStatusFields(profile);
    this.syncOrganizationListInputs(rest);
    return rest;
  }

  syncOrganizationListInputs(profile) {
    Object.entries(ORGANIZATION_LIST_INPUT_FIELDS).forEach(
      ([field, inputProperty]) => {
        this[inputProperty] = (profile?.[field] || []).join(", ");
      }
    );
  }

  @action
  changeOrganizationList(field, event) {
    this[ORGANIZATION_LIST_INPUT_FIELDS[field]] = event.target.value;
  }
}
