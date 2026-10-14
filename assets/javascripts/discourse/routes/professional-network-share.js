import { service } from "@ember/service";
import DiscourseRoute from "discourse/routes/discourse";

// SharePageController is left open server-side (see its comment for why);
// this is what actually keeps anonymous visitors out, sending them straight
// to /login instead of loading a share form they can't use.
export default class ProfessionalNetworkShareRoute extends DiscourseRoute {
  @service currentUser;

  beforeModel(transition) {
    if (!this.currentUser) {
      transition.send("showLogin");
    }
  }
}
