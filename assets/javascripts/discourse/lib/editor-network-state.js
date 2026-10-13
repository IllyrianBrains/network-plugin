import { action } from "@ember/object";
import { toggle } from "discourse/plugins/discourse-professional-network/discourse/lib/editor-base";
import ProfessionalNetworkEditorOrganizationState from "discourse/plugins/discourse-professional-network/discourse/lib/editor-organization-state";

export default class ProfessionalNetworkEditorNetworkState extends ProfessionalNetworkEditorOrganizationState {
  @action
  changeAspirationField(event) {
    this.aspirationField = event.target.value;
  }

  @action
  changeAspirationSubfield(event) {
    this.aspirationSubfield = event.target.value;
  }

  @action
  changeAspirationsNote(event) {
    this.aspirationsNote = event.target.value;
  }

  @action
  changeReturnPlan(event) {
    this.returnPlan = event.target.value;
  }

  @action
  changePronouns(event) {
    this.pronouns = event.target.value;
  }

  @action
  changeLinkedinUrl(event) {
    this.linkedinUrl = event.target.value;
  }

  @action
  changeWebsiteUrl(event) {
    this.websiteUrl = event.target.value;
  }

  @action
  changeGithubUrl(event) {
    this.githubUrl = event.target.value;
  }

  @action
  changeTwitterUrl(event) {
    this.twitterUrl = event.target.value;
  }

  @action
  changePortfolioUrl(event) {
    this.portfolioUrl = event.target.value;
  }

  @action
  changeCalendarUrl(event) {
    this.calendarUrl = event.target.value;
  }

  @action
  changeOpenToWork(event) {
    this.openToWork = event.target.checked;
  }

  @action
  changeHiring(event) {
    this.hiring = event.target.checked;
  }

  @action
  changeOpenToCollaboration(event) {
    this.openToCollaboration = event.target.checked;
  }

  @action
  changeOpenToSpeaking(event) {
    this.openToSpeaking = event.target.checked;
  }

  @action
  changeOpenToVolunteering(event) {
    this.openToVolunteering = event.target.checked;
  }

  @action
  changeOpenToRelocation(event) {
    this.openToRelocation = event.target.checked;
  }

  @action
  changeExperienceLevel(event) {
    this.experienceLevel = event.target.value;
  }

  @action
  changeAvailability(event) {
    this.availability = event.target.value;
  }

  @action
  changeOpenToConsulting(event) {
    this.openToConsulting = event.target.checked;
  }

  @action
  changePricing(event) {
    this.pricing = event.target.value;
  }

  @action
  changeMinimumEngagement(event) {
    this.minimumEngagement = event.target.value;
  }

  @action
  changeBusinessUsername(event) {
    this.businessUsername = event.target.value;
  }

  @action
  addService() {
    this.services = [
      ...this.services,
      { title: "", rate: "", description: "" },
    ];
    this.markDirty();
  }

  @action
  removeService(index) {
    this.services = this.services.filter((_, i) => i !== index);
    this.markDirty();
  }

  @action
  changeServiceField(index, field, event) {
    const value = event.target.value;
    this.services = this.services.map((offering, i) =>
      i === index ? { ...offering, [field]: value } : offering
    );
  }

  @action
  toggleMentoringInterest(value) {
    this.mentoringInterests = toggle(this.mentoringInterests, value);
  }

  @action
  toggleMentoringWantedType(value) {
    this.mentoringWantedTypes = toggle(this.mentoringWantedTypes, value);
  }

  @action
  toggleMentoringProvidedType(value) {
    this.mentoringProvidedTypes = toggle(this.mentoringProvidedTypes, value);
  }

  @action
  changeMentoringNote(event) {
    this.mentoringNote = event.target.value;
  }

  @action
  toggleBusinessInterest(value) {
    this.businessInterests = toggle(this.businessInterests, value);
  }

  @action
  moveRecommendationPriority(key, direction) {
    const priorities = [...this.recommendationPriorities];
    const from = priorities.indexOf(key);
    const to = from + direction;
    if (from < 0 || to < 0 || to >= priorities.length) {
      return;
    }

    [priorities[from], priorities[to]] = [priorities[to], priorities[from]];
    this.recommendationPriorities = priorities;
  }

  @action
  toggleReturnCountry(value) {
    this.returnCountries = toggle(this.returnCountries, value);
  }
}
