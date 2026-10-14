import { service } from "@ember/service";
import DiscourseRoute from "discourse/routes/discourse";

// ProfilePageController is left open server-side so the SPA can boot from
// here too, but editing a profile needs a member -- send anonymous
// visitors straight to login rather than loading a page they can't use.
export default class ProfessionalNetworkProfileRoute extends DiscourseRoute {
  @service currentUser;

  beforeModel(transition) {
    if (!this.currentUser) {
      transition.send("showLogin");
    }
  }
}
