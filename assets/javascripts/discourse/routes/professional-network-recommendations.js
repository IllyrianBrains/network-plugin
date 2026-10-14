import { service } from "@ember/service";
import DiscourseRoute from "discourse/routes/discourse";

// RecommendationsPageController is left open server-side so the SPA can
// boot from here too, but recommendations need a member to recommend
// things to -- send anonymous visitors straight to login rather than
// loading a page they can't use.
export default class ProfessionalNetworkRecommendationsRoute extends DiscourseRoute {
  @service currentUser;

  beforeModel(transition) {
    if (!this.currentUser) {
      transition.send("showLogin");
    }
  }
}
