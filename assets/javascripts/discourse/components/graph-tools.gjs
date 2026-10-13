import DButton from "discourse/ui-kit/d-button";

const ProfessionalNetworkGraphTools = <template>
  <div
    aria-label="Graph view controls"
    class="professional-network-graph__tools"
    role="group"
  >
    <DButton
      class="btn-flat"
      @action={{@graph.zoomIn}}
      @icon="magnifying-glass-plus"
      @translatedTitle="Zoom in"
    />
    <DButton
      class="btn-flat"
      @action={{@graph.zoomOut}}
      @icon="magnifying-glass-minus"
      @translatedTitle="Zoom out"
    />
    <DButton
      class="btn-flat"
      @action={{@graph.fitView}}
      @icon="expand"
      @translatedTitle="Fit to view"
    />
  </div>
</template>;

export default ProfessionalNetworkGraphTools;
