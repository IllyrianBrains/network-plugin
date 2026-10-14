import { service } from "@ember/service";
import DiscourseRoute from "discourse/routes/discourse";

// DirectoryPageController is left open server-side so the SPA can boot from
// here too, but the member directory itself needs a member -- send
// anonymous visitors straight to login rather than loading a page they
// can't use.
export default class ProfessionalNetworkDirectoryRoute extends DiscourseRoute {
  @service currentUser;

  beforeModel(transition) {
    if (!this.currentUser) {
      transition.send("showLogin");
    }
  }
}
