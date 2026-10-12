import { on } from "@ember/modifier";
import { eq } from "discourse/truth-helpers";
import ProfessionalNetworkDirectoryTable from "discourse/plugins/discourse-professional-network/discourse/components/professional-network-directory-table";

const ProfessionalNetworkDirectoryResults = <template>
  {{#if @directory.error}}
    <p
      class="professional-network-graph__status professional-network-error"
    >Could not load the member directory.</p>
  {{else if @directory.loading}}
    <p class="professional-network-graph__status">Searching…</p>
  {{else if @directory.searched}}
    <div class="professional-network-directory__toolbar">
      <p class="professional-network-graph__status">{{@directory.resultCount}}
        member{{if (eq @directory.resultCount 1) "" "s"}}
        found.</p>
      {{#if @directory.selected.length}}
        <div class="professional-network-directory__selection">
          <span>{{@directory.selected.length}} selected</span>
          <button
            class="btn btn-flat"
            type="button"
            {{on "click" @directory.clearSelection}}
          >Clear selection</button>
        </div>
      {{/if}}
    </div>
    <ProfessionalNetworkDirectoryTable @directory={{@directory}} />
  {{/if}}
</template>;

export default ProfessionalNetworkDirectoryResults;
