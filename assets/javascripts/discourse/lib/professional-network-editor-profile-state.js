import { action } from "@ember/object";
import { ajax } from "discourse/lib/ajax";
import ProfessionalNetworkEditorBase from "discourse/plugins/discourse-professional-network/discourse/lib/professional-network-editor-base";

export default class ProfessionalNetworkEditorProfileState extends ProfessionalNetworkEditorBase {
  async loadProfile() {
    try {
      const result = await ajax(
        `/professional-network/profiles/${encodeURIComponent(this.currentUser.username)}`
      );
      this.profile = result.profile;
      this.profileData = this.splitStatusFields(result.profile || {});
      this.publicProfile = result.public_profile;
      this.timezone = result.timezone;
      this.syncAspirationFields(result.aspirations);
      this.dirty = false;
    } catch {
      // No profile yet: still give the member an empty editor to work from,
      // rather than hiding the form until they import a LinkedIn PDF.
      this.profile = null;
      this.profileData = {};
      this.syncAspirationFields();
      this.dirty = false;
    }
  }

  // Pulls fields edited on other tabs out of the main profile form.
  splitStatusFields(profile) {
    const {
      pronouns,
      linkedin_url,
      website,
      github_url,
      twitter_url,
      portfolio_url,
      calendar_url,
      open_to_work,
      hiring,
      open_to_collaboration,
      open_to_speaking,
      open_to_volunteering,
      open_to_relocation,
      experience_level,
      availability,
      open_to_consulting,
      freelance_rate,
      minimum_project_size,
      services,
      ...rest
    } = profile;
    this.pronouns = pronouns || "";
    this.linkedinUrl = linkedin_url || "";
    this.websiteUrl = website || "";
    this.githubUrl = github_url || "";
    this.twitterUrl = twitter_url || "";
    this.portfolioUrl = portfolio_url || "";
    this.calendarUrl = calendar_url || "";
    this.openToWork = !!open_to_work;
    this.hiring = !!hiring;
    this.openToCollaboration = !!open_to_collaboration;
    this.openToSpeaking = !!open_to_speaking;
    this.openToVolunteering = !!open_to_volunteering;
    this.openToRelocation = !!open_to_relocation;
    this.experienceLevel = experience_level || "";
    this.availability = availability || "";
    this.openToConsulting = !!open_to_consulting;
    this.pricing = freelance_rate || "";
    this.minimumEngagement = minimum_project_size || "";
    this.services = services || [];
    this.fieldsOfExpertiseInput = (rest.fields_of_expertise || []).join(", ");
    this.skillsInput = (rest.skills || []).join(", ");
    this.languagesInput = (rest.languages || []).join(", ");
    this.certificationsInput = (rest.certifications || []).join(", ");
    this.preferredLocationsInput = (rest.preferred_locations || []).join(", ");
    rest.experience = (rest.experience || []).map((entry) => ({
      ...entry,
      title: entry.title || entry.role || "",
      organization: entry.organization || entry.company || "",
      start_year: entry.start_year ?? entry.startYear ?? "",
      end_year: entry.end_year ?? entry.endYear ?? "",
      is_current: entry.is_current ?? entry.current ?? false,
    }));
    rest.education = (rest.education || []).map((entry) => ({
      ...entry,
      school: entry.school || entry.institution || "",
      start_year: entry.start_year ?? entry.startYear ?? "",
      end_year: entry.end_year ?? entry.endYear ?? "",
    }));
    return rest;
  }

  syncAspirationFields(aspirations) {
    this.aspirationField = aspirations?.field || "";
    this.aspirationSubfield = aspirations?.subfield || "";
    this.mentoringInterests = aspirations?.mentoring_interests || [];
    this.mentoringWantedTypes = aspirations?.mentoring_wanted_types || [];
    this.mentoringProvidedTypes = aspirations?.mentoring_provided_types || [];
    this.mentoringNote = aspirations?.mentoring_note || "";
    this.businessInterests = aspirations?.business_interests || [];
    this.aspirationsNote = aspirations?.note || "";
    this.returnPlan = aspirations?.return_plan || "";
    this.returnCountries = aspirations?.return_countries || [];
  }

  @action
  showTab(tab) {
    this.activeTab = tab;
  }

  @action
  markDirty(event) {
    if (event?.target?.type === "file") {
      return;
    }
    this.dirty = true;
    this.message = null;
  }

  @action
  chooseFile(event) {
    this.selectedFile = event.target.files?.[0] || null;
  }

  @action
  changeProfileField(field, event) {
    this.profileData = { ...this.profileData, [field]: event.target.value };
  }

  @action
  changeProfileCheckbox(field, event) {
    this.profileData = { ...this.profileData, [field]: event.target.checked };
  }

  @action
  changeListField(field, event) {
    const value = event.target.value;
    if (field === "fields_of_expertise") {
      this.fieldsOfExpertiseInput = value;
    } else if (field === "skills") {
      this.skillsInput = value;
    } else if (field === "languages") {
      this.languagesInput = value;
    } else if (field === "certifications") {
      this.certificationsInput = value;
    } else if (field === "preferred_locations") {
      this.preferredLocationsInput = value;
    }
  }

  @action
  addEntry(collection) {
    const blank =
      collection === "experience"
        ? {
            title: "",
            organization: "",
            location: "",
            start_year: "",
            end_year: "",
            is_current: false,
            description: "",
          }
        : { school: "", degree: "", field: "", start_year: "", end_year: "" };
    this.profileData = {
      ...this.profileData,
      [collection]: [...(this.profileData[collection] || []), blank],
    };
    this.markDirty();
  }

  @action
  changeEntry(collection, index, field, event) {
    const value =
      event.target.type === "checkbox"
        ? event.target.checked
        : event.target.value;
    const entries = (this.profileData[collection] || []).map(
      (entry, entryIndex) =>
        entryIndex === index
          ? {
              ...entry,
              [field]: value,
              ...(field === "is_current" && value ? { end_year: "" } : {}),
            }
          : entry
    );
    this.profileData = { ...this.profileData, [collection]: entries };
  }

  @action
  removeEntry(collection, index) {
    const entries = (this.profileData[collection] || []).filter(
      (_, entryIndex) => entryIndex !== index
    );
    this.profileData = { ...this.profileData, [collection]: entries };
    this.markDirty();
  }

  @action
  changeVisibility(event) {
    this.publicProfile = event.target.checked;
  }
}
