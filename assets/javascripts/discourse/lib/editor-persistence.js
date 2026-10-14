import { action } from "@ember/object";
import { ajax } from "discourse/lib/ajax";
import {
  parseList,
  parseSemicolonList,
} from "discourse/plugins/discourse-professional-network/discourse/lib/editor-base";
import ProfessionalNetworkEditorNetworkState from "discourse/plugins/discourse-professional-network/discourse/lib/editor-network-state";

export default class ProfessionalNetworkEditorPersistence extends ProfessionalNetworkEditorNetworkState {
  @action
  async confirmProfileAccurate() {
    await ajax("/network/profile/review", { type: "POST" });
    this.message = "Profile marked as reviewed.";
  }

  @action
  async resetProfile() {
    const confirmed = await this.dialog.deleteConfirm({
      title: "Reset professional profile?",
      message:
        "All professional profile information, projects, networking preferences, private return-plan answers, and pending imports will be permanently deleted. Forum posts and shared LinkedIn topics will remain. You can then choose Person or Organization again.",
      confirmButtonLabel: "professional_network.reset.confirm_button",
    });
    if (!confirmed) {
      return;
    }

    this.loading = true;
    this.error = null;
    try {
      await ajax(
        `/network/profiles/${encodeURIComponent(this.targetUsername)}`,
        { type: "DELETE" },
      );
      window.location.reload();
    } catch (error) {
      this.error = this.saveError(
        error,
        "Could not reset the professional profile",
      );
      this.loading = false;
    }
  }

  @action
  async upload(event) {
    event.preventDefault();
    if (!this.selectedFile) {
      return;
    }
    this.loading = true;
    this.error = null;
    this.message = null;
    try {
      const form = new FormData();
      form.append("file", this.selectedFile);
      const response = await ajax("/network/imports", {
        type: "POST",
        data: form,
        processData: false,
        contentType: false,
      });
      this.draft = response;
      this.profileData = this.splitStatusFields(response.preview || {});
      this.dirty = true;
      this.message = "Extraction complete. Review the data before saving.";
    } catch (error) {
      this.error =
        error?.jqXHR?.responseJSON?.error || error.message || "Import failed";
    } finally {
      this.loading = false;
    }
  }

  @action
  async save() {
    if (this.accountType === "organization") {
      await this.saveOrganization();
      return;
    }
    this.loading = true;
    this.error = null;
    this.fieldErrors = {};
    try {
      const data = { ...this.profileData };
      data.fields_of_expertise = parseList(this.fieldsOfExpertiseInput);
      data.skills = parseList(this.skillsInput);
      data.languages = parseList(this.languagesInput);
      data.certifications = parseSemicolonList(this.certificationsInput);
      data.preferred_locations = parseList(this.preferredLocationsInput);
      data.experience = (data.experience || []).map((entry) => ({
        ...entry,
        start_year: entry.start_year ? Number(entry.start_year) : null,
        end_year:
          entry.is_current || !entry.end_year ? null : Number(entry.end_year),
      }));
      data.education = (data.education || []).map((entry) => ({
        ...entry,
        start_year: entry.start_year ? Number(entry.start_year) : null,
        end_year: entry.end_year ? Number(entry.end_year) : null,
      }));
      data.pronouns = this.pronouns.trim();
      data.linkedin_url = this.linkedinUrl.trim();
      data.website = this.websiteUrl.trim();
      data.github_url = this.githubUrl.trim();
      data.twitter_url = this.twitterUrl.trim();
      data.portfolio_url = this.portfolioUrl.trim();
      data.calendar_url = this.calendarUrl.trim();
      data.open_to_work = this.openToWork;
      data.hiring = this.hiring;
      data.open_to_collaboration = this.openToCollaboration;
      data.open_to_speaking = this.openToSpeaking;
      data.open_to_volunteering = this.openToVolunteering;
      data.open_to_relocation = this.openToRelocation;
      data.experience_level = this.experienceLevel;
      data.availability = this.availability;
      data.open_to_consulting = this.openToConsulting;
      data.freelance_rate = this.pricing.trim();
      data.minimum_project_size = this.minimumEngagement.trim();
      data.organization_usernames = parseList(
        this.organizationUsernamesInput,
      );
      data.services = this.services
        .map((offering) => ({
          title: offering.title.trim(),
          rate: offering.rate.trim(),
          description: offering.description.trim(),
        }))
        .filter((offering) => offering.title);
      const aspirations = {
        field: this.aspirationField.trim(),
        subfield: this.aspirationSubfield.trim(),
        mentoring_interests: this.mentoringInterests,
        mentoring_wanted_types: this.mentoringWantedTypes,
        mentoring_provided_types: this.mentoringProvidedTypes,
        mentoring_note: this.mentoringNote.trim(),
        business_interests: this.businessInterests,
        note: this.aspirationsNote.trim(),
        return_plan: this.returnPlan,
        return_countries:
          this.returnPlan === "yes" ||
          this.returnPlan === "maybe" ||
          this.returnPlan === "already_there"
            ? this.returnCountries
            : [],
        recommendation_priorities: this.recommendationPriorities,
      };
      if (this.draft) {
        await ajax(`/network/imports/${this.draft.id}`, {
          type: "PUT",
          data: JSON.stringify({ data }),
          contentType: "application/json",
        });
        await ajax(`/network/imports/${this.draft.id}/confirm`, {
          type: "POST",
        });
        this.draft = null;
      }
      const result = await ajax(
        `/network/profiles/${encodeURIComponent(this.targetUsername)}`,
        {
          type: "PUT",
          data: JSON.stringify({
            data,
            aspirations,
            public_profile: this.publicProfile,
            profile_type: "person",
          }),
          contentType: "application/json",
        },
      );
      this.profile = result.profile;
      this.profileData = this.splitStatusFields(result.profile || {});
      this.timezone = result.timezone;
      this.syncAspirationFields(result.aspirations);
      this.dirty = false;
      this.message = "Professional profile saved.";
    } catch (error) {
      this.error = this.saveError(
        error,
        "Could not save the professional profile",
      );
    } finally {
      this.loading = false;
    }
  }

  async saveOrganization() {
    this.loading = true;
    this.error = null;
    this.fieldErrors = {};
    try {
      const data = {
        ...this.profileData,
        organization_type_other:
          this.profileData.organization_type === "other"
            ? (this.profileData.organization_type_other || "").trim()
            : "",
        organization_offerings: parseList(this.organizationOfferingsInput),
        organization_opportunities: parseList(
          this.organizationOpportunitiesInput,
        ),
        organization_needs: parseList(this.organizationNeedsInput),
        collaboration_interests: parseList(this.collaborationInterestsInput),
        organization_locations: parseList(this.organizationLocationsInput),
        organization_projects: (this.profileData.organization_projects || [])
          .map((project) => ({
            name: (project.name || "").trim(),
            description: (project.description || "").trim(),
            upcoming: (project.upcoming || "").trim(),
            status: (project.status || "active").trim(),
            starts_on: (project.starts_on || "").trim(),
            ends_on: (project.ends_on || "").trim(),
          }))
          .filter((project) => project.name),
        organization_contacts: (this.profileData.organization_contacts || [])
          .map((contact) => ({
            name: (contact.name || "").trim(),
            role: (contact.role || "").trim(),
            url: (contact.url || "").trim(),
          }))
          .filter((contact) => contact.name),
        organization_opportunity_details: (
          this.profileData.organization_opportunity_details || []
        )
          .map((opportunity) => ({
            kind: (opportunity.kind || "").trim(),
            title: (opportunity.title || "").trim(),
            description: (opportunity.description || "").trim(),
            url: (opportunity.url || "").trim(),
            expires_on: (opportunity.expires_on || "").trim(),
          }))
          .filter((opportunity) => opportunity.title),
      };
      const result = await ajax(
        `/network/profiles/${encodeURIComponent(this.targetUsername)}`,
        {
          type: "PUT",
          data: JSON.stringify({
            data,
            profile_type: "organization",
            public_profile: this.publicProfile,
          }),
          contentType: "application/json",
        },
      );
      this.profile = result.profile;
      this.profileData = result.profile || {};
      this.syncOrganizationListInputs(result.profile);
      this.dirty = false;
      this.message = "Organization profile saved.";
    } catch (error) {
      this.error = this.saveError(
        error,
        "Could not save the organization profile",
      );
    } finally {
      this.loading = false;
    }
  }

  saveError(error, fallback) {
    const message =
      error?.jqXHR?.responseJSON?.errors?.join(" ") ||
      error?.jqXHR?.responseJSON?.error ||
      error?.message ||
      fallback;
    const parameter = message.match(
      /invalid parameters[^:]*:\s*([a-z0-9_]+)/i,
    )?.[1];
    if (parameter && this.showTabForInvalidParameter(parameter)) {
      this.fieldErrors = { [parameter]: message };
      return null;
    }
    return message;
  }

  showTabForInvalidParameter(parameter) {
    if (parameter.startsWith("mentoring_")) {
      this.activeTab = "mentoring";
      this.sectionsExpanded = true;
      return true;
    }
    return false;
  }
}
