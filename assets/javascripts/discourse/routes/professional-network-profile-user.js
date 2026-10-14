import { service } from "@ember/service";
import DiscourseRoute from "discourse/routes/discourse";

// This is the admin-edit-another-member's-profile route; it needs a member
// (checked again, admin-or-self, server-side) -- send anonymous visitors
// straight to login rather than loading a page they can't use.
export default class ProfessionalNetworkProfileUserRoute extends DiscourseRoute {
  @service currentUser;

  beforeModel(transition) {
    if (!this.currentUser) {
      transition.send("showLogin");
    }
  }

  model(params) {
    return { username: params.username };
  }
}
