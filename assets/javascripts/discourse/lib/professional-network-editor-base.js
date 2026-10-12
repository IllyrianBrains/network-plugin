// These fields are consumed and mutated by the focused editor state subclasses.
/* eslint-disable discourse/no-unnecessary-tracked, discourse/no-unused-services */

import Component from "@glimmer/component";
import { tracked } from "@glimmer/tracking";
import { service } from "@ember/service";

export function toggle(list, value) {
  return list.includes(value)
    ? list.filter((item) => item !== value)
    : [...list, value];
}

export function parseList(value) {
  return [
    ...new Set(
      value
        .split(",")
        .map((item) => item.trim())
        .filter(Boolean)
    ),
  ];
}

export default class ProfessionalNetworkEditorBase extends Component {
  @service currentUser;

  @tracked activeTab = "linkedin";

  @tracked profile = null;
  @tracked profileData = {};
  @tracked draft = null;
  @tracked selectedFile = null;
  @tracked publicProfile = false;
  @tracked loading = false;
  @tracked dirty = false;
  @tracked error = null;
  @tracked message = null;
  @tracked fieldsOfExpertiseInput = "";
  @tracked skillsInput = "";
  @tracked languagesInput = "";
  @tracked certificationsInput = "";
  @tracked preferredLocationsInput = "";

  @tracked aspirationField = "";
  @tracked aspirationSubfield = "";
  @tracked mentoringInterests = [];
  @tracked mentoringWantedTypes = [];
  @tracked mentoringProvidedTypes = [];
  @tracked mentoringNote = "";
  @tracked businessInterests = [];
  @tracked aspirationsNote = "";
  @tracked returnPlan = "";
  @tracked returnCountries = [];

  @tracked pronouns = "";
  @tracked linkedinUrl = "";
  @tracked websiteUrl = "";
  @tracked githubUrl = "";
  @tracked twitterUrl = "";
  @tracked portfolioUrl = "";
  @tracked calendarUrl = "";
  @tracked openToWork = false;
  @tracked hiring = false;
  @tracked openToCollaboration = false;
  @tracked openToSpeaking = false;
  @tracked openToVolunteering = false;
  @tracked openToRelocation = false;
  @tracked experienceLevel = "";
  @tracked timezone = null;

  @tracked availability = "";
  @tracked openToConsulting = false;
  @tracked pricing = "";
  @tracked minimumEngagement = "";
  @tracked services = [];

  constructor() {
    super(...arguments);
    this.loadProfile();
  }

  get experienceCount() {
    return (this.profileData.experience || []).length;
  }

  get educationCount() {
    return (this.profileData.education || []).length;
  }

  get expertiseCount() {
    return parseList(this.fieldsOfExpertiseInput).length;
  }

  get uploadDisabled() {
    return this.loading || !this.selectedFile;
  }

  get completionPercent() {
    const checks = this.completionItems.map((item) => item.complete);
    return Math.round(
      (checks.filter((value) => Boolean(value)).length / checks.length) * 100
    );
  }

  get completionItems() {
    return [
      {
        label: "Name and headline",
        complete: !!(this.profileData.name && this.profileData.headline),
      },
      {
        label: "Location and bio",
        complete: !!(
          (this.profileData.city || this.profileData.location) &&
          this.profileData.about
        ),
      },
      {
        label: "Industry and current role",
        complete: !!(
          this.profileData.industry && this.profileData.current_role
        ),
      },
      {
        label: "Expertise and skills",
        complete:
          this.expertiseCount > 0 && parseList(this.skillsInput).length > 0,
      },
      { label: "Professional level", complete: !!this.experienceLevel },
      {
        label: "Experience or education",
        complete: this.experienceCount > 0 || this.educationCount > 0,
      },
      {
        label: "What you can offer",
        complete: !!this.profileData.can_help_with,
      },
      {
        label: "What you are looking for",
        complete: !!this.profileData.looking_for,
      },
      {
        label: "Ideal connection",
        complete: !!this.profileData.ideal_connection,
      },
      {
        label: "Introduction preferences",
        complete: !!(
          this.profileData.contact_preference &&
          this.profileData.meeting_preference
        ),
      },
      {
        label: "Availability and timing",
        complete: !!this.profileData.availability_timing,
      },
      { label: "Next step", complete: !!this.aspirationField },
    ];
  }
}
