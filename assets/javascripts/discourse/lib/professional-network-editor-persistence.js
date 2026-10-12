import { action } from "@ember/object";
import { ajax } from "discourse/lib/ajax";
import { parseList } from "discourse/plugins/discourse-professional-network/discourse/lib/professional-network-editor-base";
import ProfessionalNetworkEditorNetworkState from "discourse/plugins/discourse-professional-network/discourse/lib/professional-network-editor-network-state";

export default class ProfessionalNetworkEditorPersistence extends ProfessionalNetworkEditorNetworkState {
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
      const response = await ajax("/professional-network/imports", {
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
    this.loading = true;
    this.error = null;
    try {
      const data = { ...this.profileData };
      data.fields_of_expertise = parseList(this.fieldsOfExpertiseInput);
      data.skills = parseList(this.skillsInput);
      data.languages = parseList(this.languagesInput);
      data.certifications = parseList(this.certificationsInput);
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
      };
      if (this.draft) {
        await ajax(`/professional-network/imports/${this.draft.id}`, {
          type: "PUT",
          data: JSON.stringify({ data }),
          contentType: "application/json",
        });
        await ajax(`/professional-network/imports/${this.draft.id}/confirm`, {
          type: "POST",
        });
        this.draft = null;
      }
      const result = await ajax("/professional-network/profile", {
        type: "PUT",
        data: JSON.stringify({
          data,
          aspirations,
          public_profile: this.publicProfile,
        }),
        contentType: "application/json",
      });
      this.profile = result.profile;
      this.profileData = this.splitStatusFields(result.profile || {});
      this.timezone = result.timezone;
      this.syncAspirationFields(result.aspirations);
      this.dirty = false;
      this.message = "Professional profile saved.";
    } catch (error) {
      this.error = error.message || "Could not save the professional profile";
    } finally {
      this.loading = false;
    }
  }
}
