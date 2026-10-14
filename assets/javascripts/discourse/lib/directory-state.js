import { tracked } from "@glimmer/tracking";
import { action } from "@ember/object";
import { service } from "@ember/service";
import { modifier } from "ember-modifier";
import { ajax } from "discourse/lib/ajax";
import ProfessionalNetworkDirectoryFilterState from "discourse/plugins/discourse-professional-network/discourse/lib/directory-filter-state";
import { buildDirectoryRows } from "discourse/plugins/discourse-professional-network/discourse/lib/directory-rows";
import { MENTORING_LABELS } from "discourse/plugins/discourse-professional-network/discourse/lib/mentoring";
import {
  AVAILABILITY_LABELS,
  BUSINESS_LABELS,
  EXPERIENCE_LEVEL_LABELS,
  EXPERIENCE_LEVEL_OPTIONS,
} from "discourse/plugins/discourse-professional-network/discourse/lib/options";

const FIELD_LABELS = {
  q: "Search",
  city: "City",
  country: "Country",
  field: "Field of expertise",
  skill: "Skill",
  industry: "Industry",
  experience_level: "Experience level",
  availability: "Availability",
  open_to_consulting: "Open to consulting",
  offering_services: "Offering services",
  aspiration_field: "Aspiration field",
  aspiration_subfield: "Aspiration subfield",
  mentoring_interest: "Mentoring interest",
  business_interest: "Looking for",
  include_unpublished: "Show all network accounts",
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
  industry: "",
  experience_level: "",
  availability: "",
  open_to_consulting: false,
  offering_services: false,
  aspiration_field: "",
  aspiration_subfield: "",
  mentoring_interest: "",
  business_interest: "",
  include_unpublished: false,
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
  updated_at: (result) => result.profile_updated_at || "",
};

function toggle(list, value) {
  return list.includes(value)
    ? list.filter((item) => item !== value)
    : [...list, value];
}

export default class ProfessionalNetworkDirectory extends ProfessionalNetworkDirectoryFilterState {
  @service currentUser;

  @tracked filters = { ...EMPTY_FILTERS };
  @tracked profiles = [];
  @tracked selected = [];
  @tracked expanded = [];
  @tracked sortKey = "name";
  @tracked sortDirection = "asc";
  @tracked loading = false;
  @tracked searched = false;
  @tracked error = false;
  @tracked page = 1;
  @tracked perPage = 25;
  @tracked totalCount = 0;

  setIndeterminate = modifier((element, [value]) => {
    element.indeterminate = value;
  });

  constructor() {
    super(...arguments);
    this.restoreFiltersFromUrl();
    this.search(this.page);
  }

  get resultCount() {
    return this.totalCount;
  }

  get totalPages() {
    return Math.max(1, Math.ceil(this.totalCount / this.perPage));
  }

  get hasPreviousPage() {
    return this.page > 1;
  }

  get hasNextPage() {
    return this.page < this.totalPages;
  }

  get emptyFilters() {
    return EMPTY_FILTERS;
  }

  get canShowAllAccounts() {
    return Boolean(this.currentUser?.staff);
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

  restoreFiltersFromUrl() {
    const query = new URLSearchParams(window.location.search);
    this.page = Math.max(Number.parseInt(query.get("page"), 10) || 1, 1);
    this.filters = Object.fromEntries(
      Object.entries(EMPTY_FILTERS).map(([key, fallback]) => {
        const value = query.get(key);
        return [
          key,
          typeof fallback === "boolean" ? value === "true" : value || fallback,
        ];
      })
    );
  }

  syncFiltersToUrl() {
    const query = new URLSearchParams();
    Object.entries(this.filters).forEach(([key, value]) => {
      if (value !== "" && value !== false) {
        query.set(key, value);
      }
    });
    if (this.page > 1) {
      query.set("page", this.page);
    }
    window.history.replaceState(
      {},
      "",
      query.size ? `?${query}` : window.location.pathname
    );
  }

  describeFilter(key, value) {
    if (value === true) {
      return FIELD_LABELS[key];
    }
    const lookup = VALUE_LABELS[key];
    return `${FIELD_LABELS[key]}: ${lookup ? lookup[value] || value : value}`;
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
  toggleSort(key) {
    if (!SORT_ACCESSORS[key]) {
      return;
    }
    if (this.sortKey === key) {
      this.sortDirection = this.sortDirection === "asc" ? "desc" : "asc";
    } else {
      this.sortKey = key;
      this.sortDirection = key === "updated_at" ? "desc" : "asc";
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

  @action
  previousPage() {
    if (this.hasPreviousPage) {
      this.search(this.page - 1);
    }
  }

  @action
  nextPage() {
    if (this.hasNextPage) {
      this.search(this.page + 1);
    }
  }

  async search(page = 1) {
    this.page = page;
    this.syncFiltersToUrl();
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
      const response = await ajax("/network/profiles", {
        data: { ...params, page: this.page },
      });
      this.profiles = response.profiles || [];
      this.page = response.pagination?.page || 1;
      this.perPage = response.pagination?.per_page || 25;
      this.totalCount = response.pagination?.total_count || 0;
    } catch {
      this.profiles = [];
      this.error = true;
    } finally {
      this.loading = false;
      this.searched = true;
    }
  }
}
