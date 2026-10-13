import { fn } from "@ember/helper";
import { on } from "@ember/modifier";

const ProfessionalNetworkAccountType = <template>
  <section class="professional-network-account-type">
    <p class="professional-network-panel__eyebrow">Professional network account</p>
    <h2>What does this account represent?</h2>
    <p>Choose once. A person and an organization use separate forum accounts,
      profiles, and logins.</p>
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
</template>;

export default ProfessionalNetworkAccountType;
