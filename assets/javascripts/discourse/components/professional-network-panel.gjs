import ProfessionalNetworkPanelHeader from "discourse/plugins/discourse-professional-network/discourse/components/professional-network-panel-header";
import ProfessionalNetworkPanelLinkedin from "discourse/plugins/discourse-professional-network/discourse/components/professional-network-panel-linkedin";
import ProfessionalNetworkPanelTabs from "discourse/plugins/discourse-professional-network/discourse/components/professional-network-panel-tabs";
import ProfessionalNetworkPanelState from "discourse/plugins/discourse-professional-network/discourse/lib/professional-network-panel-state";

export default class ProfessionalNetworkPanel extends ProfessionalNetworkPanelState {
  <template>
    {{#if this.profile}}
      <section
        aria-label="Professional profile"
        class="professional-network-panel"
      >
        <div class="professional-network-panel__summary">
          <ProfessionalNetworkPanelHeader @panel={{this}} />
        </div>
        <ProfessionalNetworkPanelLinkedin @panel={{this}} />
        <ProfessionalNetworkPanelTabs @panel={{this}} />
      </section>
    {{/if}}
  </template>
}
