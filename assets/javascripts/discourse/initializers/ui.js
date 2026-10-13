import { withPluginApi } from "discourse/lib/plugin-api";
import buildProfessionalNetworkSidebarSection from "discourse/plugins/discourse-professional-network/discourse/lib/sidebar-section";

export default {
  name: "professional-network-ui",

  initialize(owner) {
    owner.lookup("service:sidebar-state").collapseSection("tags");

    withPluginApi((api) => {
      api.modifyClass(
        "route:user.index",
        (Superclass) =>
          class extends Superclass {
            beforeModel() {
              this.router.transitionTo("user.professional-network");
            }
          }
      );

      api.addUserNavSidebarLink("profile", {
        name: "professional-network-profile",
        route: "user.professional-network",
        label: "professional_network.profile_page.user_tab",
        icon: "address-card",
      });

      api.addSidebarSection(buildProfessionalNetworkSidebarSection);
    });
  },
};
