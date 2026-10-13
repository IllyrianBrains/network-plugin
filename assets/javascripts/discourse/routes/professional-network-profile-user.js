import DiscourseRoute from "discourse/routes/discourse";

export default class ProfessionalNetworkProfileUserRoute extends DiscourseRoute {
  model(params) {
    return { username: params.username };
  }
}
