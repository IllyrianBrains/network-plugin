import { eq } from "discourse/truth-helpers";
import ProfessionalNetworkOrganizationProfile from "discourse/plugins/discourse-professional-network/discourse/components/organization-profile";
import ProfessionalNetworkPanelHeader from "discourse/plugins/discourse-professional-network/discourse/components/panel-header";
import ProfessionalNetworkPanelLinkedin from "discourse/plugins/discourse-professional-network/discourse/components/panel-linkedin";
import ProfessionalNetworkPanelTabs from "discourse/plugins/discourse-professional-network/discourse/components/panel-tabs";
import ProfessionalNetworkPanelState from "discourse/plugins/discourse-professional-network/discourse/lib/panel-state";

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
        {{#if (eq this.profileType "organization")}}
          <ProfessionalNetworkOrganizationProfile @panel={{this}} />
        {{else}}
          <ProfessionalNetworkPanelLinkedin @panel={{this}} />
          <ProfessionalNetworkPanelTabs @panel={{this}} />
        {{/if}}
      </section>
    {{/if}}
  </template>
}
