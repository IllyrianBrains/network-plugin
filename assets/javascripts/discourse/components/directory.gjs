import { service } from "@ember/service";
import ProfessionalNetworkDirectoryFilters from "discourse/plugins/discourse-professional-network/discourse/components/directory-filters";
import ProfessionalNetworkDirectoryResults from "discourse/plugins/discourse-professional-network/discourse/components/directory-results";
import ProfessionalNetworkDirectoryState from "discourse/plugins/discourse-professional-network/discourse/lib/directory-state";

export default class ProfessionalNetworkDirectory extends ProfessionalNetworkDirectoryState {
  @service siteSettings;

  <template>
    <div class="professional-network-directory">
      <header>
        <p class="professional-network-panel__eyebrow">{{this.siteSettings.professional_network_name}}</p>
        <h2>Members</h2>
        <p>Search public profiles and filter by location, expertise, and what
          members are looking for.</p>
      </header>
      <nav
        aria-label="Directory type"
        class="professional-network-directory-switcher"
      >
        <a
          aria-current="page"
          class="btn btn-flat"
          href="/network/directory"
        >Members</a>
        <a class="btn btn-flat" href="/network/organizations">Organizations</a>
      </nav>
      <ProfessionalNetworkDirectoryFilters @directory={{this}} />
      <ProfessionalNetworkDirectoryResults @directory={{this}} />
    </div>
  </template>
}
