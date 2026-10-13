import Component from "@glimmer/component";
import { action } from "@ember/object";

// Shared by the member and organization directory states: the generic
// filter-object mutation + re-search flow is identical between them, only
// the filter shape and what `search()` fetches differ.
export default class ProfessionalNetworkDirectoryFilterState extends Component {
  // Subclasses override with their own EMPTY_FILTERS constant.
  get emptyFilters() {
    return {};
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
    this.filters = { ...this.filters, [key]: this.emptyFilters[key] };
    this.search();
  }

  @action
  submit(event) {
    event.preventDefault();
    this.search();
  }

  @action
  reset() {
    this.filters = { ...this.emptyFilters };
    this.search();
  }
}
