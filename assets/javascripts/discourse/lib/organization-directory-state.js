import { tracked } from "@glimmer/tracking";
import { ajax } from "discourse/lib/ajax";
import ProfessionalNetworkDirectoryFilterState from "discourse/plugins/discourse-professional-network/discourse/lib/directory-filter-state";
import { ORGANIZATION_TYPE_LABELS } from "discourse/plugins/discourse-professional-network/discourse/lib/options";

const EMPTY_FILTERS = {
  q: "",
  city: "",
  country: "",
  organization_type: "",
  sector: "",
  stage: "",
  collaboration_interest: "",
  offers_mentoring: false,
};

const FILTER_LABELS = {
  q: "Search",
  city: "City",
  country: "Country",
  organization_type: "Type",
  sector: "Sector",
  stage: "Stage",
  collaboration_interest: "Collaboration interest",
  offers_mentoring: "Offers mentoring",
};

export default class ProfessionalNetworkOrganizationDirectoryState extends ProfessionalNetworkDirectoryFilterState {
  @tracked filters = { ...EMPTY_FILTERS };
  @tracked organizations = [];
  @tracked loading = false;
  @tracked searched = false;
  @tracked error = false;

  constructor() {
    super(...arguments);
    this.search();
  }

  get emptyFilters() {
    return EMPTY_FILTERS;
  }

  get activeFilters() {
    return Object.entries(this.filters)
      .filter(([, value]) => value)
      .map(([key, value]) => ({
        key,
        display:
          value === true
            ? FILTER_LABELS[key]
            : `${FILTER_LABELS[key]}: ${
                key === "organization_type"
                  ? ORGANIZATION_TYPE_LABELS[value] || value
                  : value
              }`,
      }));
  }

  get resultCount() {
    return this.organizations.length;
  }

  typeLabel(profile) {
    return profile.organization_type === "other"
      ? profile.organization_type_other || "Other"
      : ORGANIZATION_TYPE_LABELS[profile.organization_type] ||
          profile.organization_type;
  }

  async search() {
    this.loading = true;
    this.error = false;
    try {
      const data = Object.fromEntries(
        Object.entries({
          profile_type: "organization",
          ...this.filters,
        }).filter(([, value]) => value)
      );
      const response = await ajax("/network/profiles", { data });
      this.organizations = (response.profiles || []).map((result) => {
        const profile = {
          ...result.profile,
          organization_needs: result.profile.organization_needs || [],
          organization_offerings: result.profile.organization_offerings || [],
          organization_opportunities:
            result.profile.organization_opportunities || [],
          organization_opportunity_details:
            result.profile.organization_opportunity_details || [],
          collaboration_interests: result.profile.collaboration_interests || [],
          organization_projects: result.profile.organization_projects || [],
        };
        const opportunityKinds = profile.organization_opportunity_details.map(
          (opportunity) => opportunity.kind
        );
        const badges = [];
        if (opportunityKinds.includes("mentoring")) {
          badges.push("Offers mentoring");
        }
        if (opportunityKinds.includes("job")) {
          badges.push("Hiring");
        }
        if (opportunityKinds.includes("volunteer")) {
          badges.push("Seeking volunteers");
        }
        if (
          profile.collaboration_interests.length ||
          opportunityKinds.includes("collaboration")
        ) {
          badges.push("Open to collaboration");
        }
        return {
          ...result,
          profile,
          organizationTypeLabel: this.typeLabel(profile),
          badges,
        };
      });
    } catch {
      this.organizations = [];
      this.error = true;
    } finally {
      this.loading = false;
      this.searched = true;
    }
  }
}
