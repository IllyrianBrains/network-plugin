import { LinkTo } from "@ember/routing";
import dIcon from "discourse/ui-kit/helpers/d-icon";
import { i18n } from "discourse-i18n";

export default <template>
  <li class="user-main-nav-outlet professional-network-user-tab">
    <LinkTo @route="user.professional-network">
      {{dIcon "address-card"}}
      <span>{{i18n "professional_network.profile_page.user_tab"}}</span>
    </LinkTo>
  </li>
</template>
