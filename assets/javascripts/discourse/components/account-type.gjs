import Component from "@glimmer/component";
import { fn } from "@ember/helper";
import { on } from "@ember/modifier";
import { service } from "@ember/service";

export default class ProfessionalNetworkAccountType extends Component {
  @service siteSettings;

  <template>
  <section class="professional-network-account-type">
    <header>
      <p class="professional-network-panel__eyebrow">{{this.siteSettings.professional_network_name}}</p>
      <h2>What does this account represent?</h2>
      <p>Choose once. A person and an organization use separate forum accounts,
        profiles, and logins.</p>
    </header>
    <div class="professional-network-account-type__choices">
      <button
        disabled={{@editor.loading}}
        type="button"
        {{on "click" (fn @editor.chooseAccountType "person")}}
      >
        <strong>Person</strong>
        <span>Career, networking, mentoring, and business interests</span>
      </button>
      <button
        disabled={{@editor.loading}}
        type="button"
        {{on "click" (fn @editor.chooseAccountType "organization")}}
      >
        <strong>Organization or business</strong>
        <span>Mission, needs, offerings, opportunities, and partnerships</span>
      </button>
    </div>
    {{#if @editor.error}}<p
        class="professional-network-error"
        role="alert"
      >{{@editor.error}}</p>{{/if}}
  </section>
  </template>
}
