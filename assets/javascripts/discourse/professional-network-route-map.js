export default function () {
  this.route("professional-network-graph", {
    path: "/network",
  });
  this.route("professional-network-profile", {
    path: "/network/profile",
  });
  this.route("professional-network-profile-user", {
    path: "/network/profile/:username",
  });
  this.route("professional-network-share", {
    path: "/network/share",
  });
  this.route("professional-network-directory", {
    path: "/network/directory",
  });
  this.route("professional-network-organizations", {
    path: "/network/organizations",
  });
  this.route("professional-network-recommendations", {
    path: "/network/recommendations",
  });
}
