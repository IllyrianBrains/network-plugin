// These fields are consumed and mutated by the focused editor state subclasses.
/* eslint-disable discourse/no-unnecessary-tracked, discourse/no-unused-services */

import Component from "@glimmer/component";
import { tracked } from "@glimmer/tracking";
import { service } from "@ember/service";
import {
  DEFAULT_RECOMMENDATION_PRIORITIES,
  RECOMMENDATION_PRIORITY_LABELS,
} from "discourse/plugins/discourse-professional-network/discourse/lib/recommendation-priorities";

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
  @service dialog;

  @tracked activeTab = "linkedin";
  @tracked organizationTab = "overview";
  @tracked accountType = null;
  @tracked profileLoaded = false;
  @tracked sectionsExpanded = false;

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
  @tracked recommendationPriorities = [...DEFAULT_RECOMMENDATION_PRIORITIES];

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
  @tracked businessUsername = "";
  @tracked services = [];

  constructor() {
    super(...arguments);
    this.loadProfile();
  }

  // Admins can edit another member's profile via
  // /network/profile/:username; everyone else edits their own.
  get targetUsername() {
    return this.args.targetUsername || this.currentUser?.username;
  }

  get isEditingOtherUser() {
    return (
      !!this.args.targetUsername &&
      this.args.targetUsername.toLowerCase() !==
        this.currentUser?.username?.toLowerCase()
    );
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

  // Return plan and Settings have no collapsible sections, so the
  // Edit all/Collapse all toggle has nothing to do there.
  get hasCollapsibleSections() {
    return !["return", "settings"].includes(this.activeTab);
  }

  get completionPercent() {
    const checks = this.completionItems.map((item) => item.complete);
    return Math.round(
      (checks.filter((value) => Boolean(value)).length / checks.length) * 100
    );
  }

  get completionItems() {
    if (this.accountType === "organization") {
      return this.organizationCompletionItems;
    }

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

  get recommendationPriorityItems() {
    return this.recommendationPriorities.map((key, index, priorities) => ({
      key,
      ...RECOMMENDATION_PRIORITY_LABELS[key],
      rank: index + 1,
      first: index === 0,
      last: index === priorities.length - 1,
    }));
  }

  get organizationCompletionItems() {
    return [
      {
        label: "Name and organization type",
        complete: !!(
          this.profileData.name &&
          this.profileData.organization_type &&
          (this.profileData.organization_type !== "other" ||
            this.profileData.organization_type_other)
        ),
      },
      {
        label: "Sector and stage",
        complete: !!(this.profileData.sector && this.profileData.stage),
      },
      {
        label: "Location",
        complete: !!(this.profileData.city && this.profileData.country),
      },
      {
        label: "Mission and description",
        complete: !!(this.profileData.mission && this.profileData.about),
      },
      {
        label: "Current needs",
        complete: (this.profileData.organization_needs || []).length > 0,
      },
      {
        label: "Products or services",
        complete: (this.profileData.organization_offerings || []).length > 0,
      },
      {
        label: "Collaboration interests",
        complete: (this.profileData.collaboration_interests || []).length > 0,
      },
      {
        label: "Projects",
        complete: (this.profileData.organization_projects || []).some(
          (project) => project.name
        ),
      },
      {
        label: "Website or LinkedIn",
        complete: !!(this.profileData.website || this.profileData.linkedin_url),
      },
    ];
  }
}
