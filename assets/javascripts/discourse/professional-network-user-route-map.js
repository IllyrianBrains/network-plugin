export default {
  resource: "user",
  path: "users/:username",
  map() {
    this.route("professional-network", { path: "professional-profile" });
  },
};
