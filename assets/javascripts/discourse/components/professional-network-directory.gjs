import ProfessionalNetworkDirectoryFilters from "discourse/plugins/discourse-professional-network/discourse/components/professional-network-directory-filters";
import ProfessionalNetworkDirectoryResults from "discourse/plugins/discourse-professional-network/discourse/components/professional-network-directory-results";
import ProfessionalNetworkDirectoryState from "discourse/plugins/discourse-professional-network/discourse/lib/professional-network-directory-state";

export default class ProfessionalNetworkDirectory extends ProfessionalNetworkDirectoryState {
  <template>
    <div class="professional-network-directory">
      <header>
        <h2>Member directory</h2>
        <p>Search public profiles and filter by location, expertise, and what
          members are looking for.</p>
      </header>
      <ProfessionalNetworkDirectoryFilters @directory={{this}} />
      <ProfessionalNetworkDirectoryResults @directory={{this}} />
    </div>
  </template>
}
