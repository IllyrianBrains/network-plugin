import DiscourseRoute from "discourse/routes/discourse";
import { i18n } from "discourse-i18n";

export default class UserProfessionalNetworkRoute extends DiscourseRoute {
  model() {
    return this.modelFor("user");
  }

  titleToken() {
    return i18n("professional_network.profile_page.user_tab");
  }
}
