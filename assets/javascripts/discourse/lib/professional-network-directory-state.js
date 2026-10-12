import Component from "@glimmer/component";
import { tracked } from "@glimmer/tracking";
import { action } from "@ember/object";
import { modifier } from "ember-modifier";
import { ajax } from "discourse/lib/ajax";
import { buildDirectoryRows } from "discourse/plugins/discourse-professional-network/discourse/lib/professional-network-directory-rows";
import { MENTORING_LABELS } from "discourse/plugins/discourse-professional-network/discourse/lib/professional-network-mentoring";
import {
  AVAILABILITY_LABELS,
  BUSINESS_LABELS,
  EXPERIENCE_LEVEL_LABELS,
  EXPERIENCE_LEVEL_OPTIONS,
} from "discourse/plugins/discourse-professional-network/discourse/lib/professional-network-options";

const FIELD_LABELS = {
  q: "Search",
  city: "City",
  country: "Country",
  field: "Field of expertise",
  skill: "Skill",
  experience_level: "Experience level",
  availability: "Availability",
  open_to_consulting: "Open to consulting",
  offering_services: "Offering services",
  aspiration_field: "Aspiration field",
  aspiration_subfield: "Aspiration subfield",
  mentoring_interest: "Mentoring interest",
  business_interest: "Looking for",
};

const VALUE_LABELS = {
  experience_level: EXPERIENCE_LEVEL_LABELS,
  availability: AVAILABILITY_LABELS,
  mentoring_interest: MENTORING_LABELS,
  business_interest: BUSINESS_LABELS,
};

const EMPTY_FILTERS = {
  q: "",
  city: "",
  country: "",
  field: "",
  skill: "",
  experience_level: "",
  availability: "",
  open_to_consulting: false,
  offering_services: false,
  aspiration_field: "",
  aspiration_subfield: "",
  mentoring_interest: "",
  business_interest: "",
};

const SORT_ACCESSORS = {
  name: (result) => (result.profile.name || "").toLowerCase(),
  company: (result) => (result.profile.company || "").toLowerCase(),
  city: (result) => (result.profile.city || "").toLowerCase(),
  country: (result) => (result.profile.country || "").toLowerCase(),
  experience_level: (result) =>
    EXPERIENCE_LEVEL_OPTIONS.findIndex(
      (option) => option.value === result.profile.experience_level
    ),
};

function toggle(list, value) {
  return list.includes(value)
    ? list.filter((item) => item !== value)
    : [...list, value];
}

export default class ProfessionalNetworkDirectory extends Component {
  @tracked filters = { ...EMPTY_FILTERS };
  @tracked profiles = [];
  @tracked selected = [];
  @tracked expanded = [];
  @tracked sortKey = "name";
  @tracked sortDirection = "asc";
  @tracked loading = false;
  @tracked searched = false;
  @tracked error = false;

  setIndeterminate = modifier((element, [value]) => {
    element.indeterminate = value;
  });

  constructor() {
    super(...arguments);
    this.search();
  }

  get resultCount() {
    return this.profiles.length;
  }

  get sortedProfiles() {
    const accessor = SORT_ACCESSORS[this.sortKey];
    if (!accessor) {
      return this.profiles;
    }
    const sorted = [...this.profiles].sort((a, b) => {
      const left = accessor(a);
      const right = accessor(b);
      if (left < right) {
        return -1;
      }
      return left > right ? 1 : 0;
    });
    return this.sortDirection === "desc" ? sorted.reverse() : sorted;
  }

  get rows() {
    return buildDirectoryRows(this.sortedProfiles);
  }

  get allSelected() {
    return (
      this.rows.length > 0 &&
      this.rows.every((row) => this.selected.includes(row.username))
    );
  }

  get someSelected() {
    return this.selected.length > 0 && !this.allSelected;
  }

  get activeFilters() {
    return Object.entries(this.filters)
      .filter(([, value]) => value !== "" && value !== false)
      .map(([key, value]) => ({
        key,
        display: this.describeFilter(key, value),
      }));
  }

  describeFilter(key, value) {
    if (value === true) {
      return FIELD_LABELS[key];
    }
    const lookup = VALUE_LABELS[key];
    return `${FIELD_LABELS[key]}: ${lookup ? lookup[value] || value : value}`;
  }

  @action
  changeFilter(field, event) {
    this.filters = { ...this.filters, [field]: event.target.value };
  }

  @action
  changeFilterAndSearch(field, event) {
    this.changeFilter(field, event);
    this.search();
  }

  @action
  changeFilterCheckbox(field, event) {
    this.filters = { ...this.filters, [field]: event.target.checked };
    this.search();
  }

  @action
  removeFilter(key) {
    this.filters = { ...this.filters, [key]: EMPTY_FILTERS[key] };
    this.search();
  }

  @action
  filterBySkill(skill) {
    this.filters = { ...this.filters, skill };
    this.search();
  }

  @action
  filterByField(field) {
    this.filters = { ...this.filters, field };
    this.search();
  }

  @action
  toggleExpand(username, event) {
    event?.stopPropagation();
    this.expanded = toggle(this.expanded, username);
  }

  @action
  submit(event) {
    event.preventDefault();
    this.search();
  }

  @action
  reset() {
    this.filters = { ...EMPTY_FILTERS };
    this.search();
  }

  @action
  toggleSort(key) {
    if (!SORT_ACCESSORS[key]) {
      return;
    }
    if (this.sortKey === key) {
      this.sortDirection = this.sortDirection === "asc" ? "desc" : "asc";
    } else {
      this.sortKey = key;
      this.sortDirection = "asc";
    }
  }

  @action
  toggleRow(username) {
    this.selected = toggle(this.selected, username);
  }

  @action
  toggleAll() {
    this.selected = this.allSelected
      ? []
      : this.rows.map((row) => row.username);
  }

  @action
  clearSelection() {
    this.selected = [];
  }

  async search() {
    this.loading = true;
    this.error = false;
    this.selected = [];
    this.expanded = [];
    try {
      const params = Object.fromEntries(
        Object.entries(this.filters).filter(
          ([, value]) => value !== "" && value !== false
        )
      );
      const response = await ajax("/professional-network/profiles", {
        data: params,
      });
      this.profiles = response.profiles || [];
    } catch {
      this.profiles = [];
      this.error = true;
    } finally {
      this.loading = false;
      this.searched = true;
    }
  }
}
