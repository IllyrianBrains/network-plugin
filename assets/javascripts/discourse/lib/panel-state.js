import Component from "@glimmer/component";
import { tracked } from "@glimmer/tracking";
import { action } from "@ember/object";
import { service } from "@ember/service";
import { ajax } from "discourse/lib/ajax";
import {
  MENTORING_LABELS,
  MENTORING_TYPE_LABELS,
} from "discourse/plugins/discourse-professional-network/discourse/lib/mentoring";
import {
  AVAILABILITY_LABELS,
  BUSINESS_LABELS,
  CONTACT_LABELS,
  EXPERIENCE_LEVEL_LABELS,
  MEETING_LABELS,
  ORGANIZATION_TYPE_LABELS,
} from "discourse/plugins/discourse-professional-network/discourse/lib/options";

export default class ProfessionalNetworkPanel extends Component {
  @service currentUser;

  @tracked profile = null;
  @tracked profileType = "person";
  @tracked aspirations = null;
  @tracked activity = [];
  @tracked linkedMembers = [];
  @tracked privacyPreview = false;
  @tracked reviewedAt = null;
  @tracked verifiedAt = null;
  @tracked stale = false;

  constructor() {
    super(...arguments);
    if (this.username) {
      this.loadProfile();
      this.loadActivity();
    }
  }

  get username() {
    return (
      this.args.outletArgs?.model?.username ||
      this.args.outletArgs?.user?.username
    );
  }

  get isOwnProfile() {
    return (
      !!this.currentUser &&
      this.currentUser.username?.toLowerCase() === this.username?.toLowerCase()
    );
  }

  get canAdminEdit() {
    return !this.isOwnProfile && !!this.currentUser?.admin;
  }

  get canVerifyOrganization() {
    return (
      this.profileType === "organization" &&
      !!this.currentUser?.staff &&
      !this.verifiedAt
    );
  }

  get availabilityLabel() {
    return AVAILABILITY_LABELS[this.profile?.availability] || null;
  }

  get experienceLevelLabel() {
    return EXPERIENCE_LEVEL_LABELS[this.profile?.experience_level] || null;
  }

  get organizationTypeLabel() {
    if (this.profile?.organization_type === "other") {
      return this.profile.organization_type_other || "Other";
    }
    return (
      ORGANIZATION_TYPE_LABELS[this.profile?.organization_type] ||
      this.profile?.organization_type
    );
  }

  get organizationProfiles() {
    const usernames =
      this.profile?.organization_usernames ||
      (this.profile?.business_username
        ? [this.profile.business_username]
        : []);
    return usernames.map((username) => ({
      username,
      url: `/u/${encodeURIComponent(username)}`,
    }));
  }

  get contactPreferenceLabel() {
    return CONTACT_LABELS[this.profile?.contact_preference] || null;
  }

  get meetingPreferenceLabel() {
    return MEETING_LABELS[this.profile?.meeting_preference] || null;
  }

  get preferredLocations() {
    return this.profile?.preferred_locations || [];
  }

  get hasIntroductions() {
    return !!(
      this.profile?.industry ||
      this.profile?.current_role ||
      this.profile?.can_help_with ||
      this.profile?.looking_for ||
      this.profile?.ideal_connection ||
      this.preferredLocations.length ||
      this.profile?.availability_timing ||
      this.profile?.contact_preference ||
      this.profile?.meeting_preference ||
      this.profile?.open_to_introductions
    );
  }

  get mentoringInterests() {
    return (this.aspirations?.mentoring_interests || [])
      .map((value) => MENTORING_LABELS[value])
      .filter(Boolean);
  }

  get mentoringWantedTypes() {
    return (this.aspirations?.mentoring_wanted_types || [])
      .map((value) => MENTORING_TYPE_LABELS[value])
      .filter(Boolean);
  }

  get mentoringProvidedTypes() {
    return (this.aspirations?.mentoring_provided_types || [])
      .map((value) => MENTORING_TYPE_LABELS[value])
      .filter(Boolean);
  }

  get hasMentoring() {
    return !!(
      this.mentoringInterests.length ||
      this.mentoringWantedTypes.length ||
      this.mentoringProvidedTypes.length ||
      this.aspirations?.mentoring_note
    );
  }

  get businessInterests() {
    return (this.aspirations?.business_interests || [])
      .map((value) => BUSINESS_LABELS[value])
      .filter(Boolean);
  }

  get hasAspirations() {
    return !!(
      this.aspirations?.field ||
      this.aspirations?.subfield ||
      this.aspirations?.note ||
      this.businessInterests.length
    );
  }

  @action
  async verifyOrganization() {
    const response = await ajax(
      `/network/profiles/${encodeURIComponent(this.username)}/verify`,
      { type: "POST" }
    );
    this.verifiedAt = response.verified_at;
  }

  @action
  togglePrivacyPreview() {
    this.privacyPreview = !this.privacyPreview;
    this.loadProfile();
  }

  async loadProfile() {
    try {
      const result = await ajax(
        `/network/profiles/${encodeURIComponent(this.username)}`,
        { data: this.privacyPreview ? { preview: "public" } : {} }
      );
      this.profile = result.profile;
      this.profileType = result.profile_type || "person";
      this.aspirations = result.aspirations || {};
      this.linkedMembers = result.linked_members || [];
      this.privacyPreview = !!result.privacy_preview;
      this.reviewedAt = result.reviewed_at;
      this.verifiedAt = result.verified_at;
      this.stale = !!result.stale;
    } catch {
      this.profile = null;
      this.aspirations = null;
      this.linkedMembers = [];
    }
  }

  async loadActivity() {
    try {
      const response = await ajax(
        `/network/profiles/${encodeURIComponent(this.username)}/activity`
      );
      this.activity = response.items || [];
    } catch {
      this.activity = [];
    }
  }
}
