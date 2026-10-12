import Component from "@glimmer/component";
import { tracked } from "@glimmer/tracking";
import { service } from "@ember/service";
import { ajax } from "discourse/lib/ajax";
import {
  MENTORING_LABELS,
  MENTORING_TYPE_LABELS,
} from "discourse/plugins/discourse-professional-network/discourse/lib/professional-network-mentoring";
import {
  AVAILABILITY_LABELS,
  BUSINESS_LABELS,
  CONTACT_LABELS,
  EXPERIENCE_LEVEL_LABELS,
  MEETING_LABELS,
} from "discourse/plugins/discourse-professional-network/discourse/lib/professional-network-options";

export default class ProfessionalNetworkPanel extends Component {
  @service currentUser;

  @tracked profile = null;
  @tracked aspirations = null;
  @tracked activity = [];

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

  get availabilityLabel() {
    return AVAILABILITY_LABELS[this.profile?.availability] || null;
  }

  get experienceLevelLabel() {
    return EXPERIENCE_LEVEL_LABELS[this.profile?.experience_level] || null;
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

  async loadProfile() {
    try {
      const result = await ajax(
        `/professional-network/profiles/${encodeURIComponent(this.username)}`
      );
      this.profile = result.profile;
      this.aspirations = result.aspirations || {};
    } catch {
      this.profile = null;
      this.aspirations = null;
    }
  }

  async loadActivity() {
    try {
      const response = await ajax(
        `/professional-network/profiles/${encodeURIComponent(this.username)}/activity`
      );
      this.activity = response.items || [];
    } catch {
      this.activity = [];
    }
  }
}
