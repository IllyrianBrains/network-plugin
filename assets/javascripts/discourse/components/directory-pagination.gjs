import { on } from "@ember/modifier";
import { not, or } from "discourse/truth-helpers";

const ProfessionalNetworkDirectoryPagination = <template>
  {{#if (or @directory.hasPreviousPage @directory.hasNextPage)}}
    <nav
      aria-label="Directory pages"
      class="professional-network-directory__pagination"
    >
      <button
        class="btn btn-default"
        disabled={{not @directory.hasPreviousPage}}
        type="button"
        {{on "click" @directory.previousPage}}
      >Previous</button>
      <span>Page {{@directory.page}} of {{@directory.totalPages}}</span>
      <button
        class="btn btn-default"
        disabled={{not @directory.hasNextPage}}
        type="button"
        {{on "click" @directory.nextPage}}
      >Next</button>
    </nav>
  {{/if}}
</template>;

export default ProfessionalNetworkDirectoryPagination;
