import { withPluginApi } from "discourse/lib/plugin-api";
import { CREATE_TOPIC } from "discourse/models/composer";
import { i18n } from "discourse-i18n";

const LINKEDIN_TEMPLATE =
  "Original LinkedIn post: https://www.linkedin.com/posts/PASTE-LINK-HERE\n\nWhy I’m sharing this:\n";

export default {
  name: "professional-network-ui",

  initialize() {
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

      api.addCommunitySectionLink(
        {
          name: "professional-network-profile",
          route: "professional-network-profile",
          title: i18n("professional_network.profile_page.title"),
          text: i18n("professional_network.profile_page.title"),
          icon: "linkedin",
        },
        true
      );

      api.addCommunitySectionLink(
        {
          name: "professional-network-graph",
          route: "professional-network-graph",
          title: i18n("professional_network.network_graph.title"),
          text: i18n("professional_network.network_graph.title"),
          icon: "diagram-project",
        },
        true
      );

      api.addCommunitySectionLink(
        {
          name: "professional-network-directory",
          route: "professional-network-directory",
          title: i18n("professional_network.directory.title"),
          text: i18n("professional_network.directory.title"),
          icon: "magnifying-glass",
        },
        true
      );

      api.addComposerAction({
        id: "create_linkedin_share",
        label: "professional_network.composer.label",
        description: "professional_network.composer.description",
        icon: "linkedin",
        condition: (component) => {
          const composer = component.composerModel;
          return (
            composer?.action === CREATE_TOPIC && !composer.creatingLinkedInShare
          );
        },
        action: (composer) => {
          composer.set("creatingLinkedInShare", true);
          composer.notifyPropertyChange("category");
          if (!(composer.reply || "").includes("Original LinkedIn post:")) {
            composer.appendText(LINKEDIN_TEMPLATE, null, { new_line: true });
          }
        },
      });

      api.addComposerAction({
        id: "create_regular_topic_from_linkedin",
        label: "professional_network.composer.regular_label",
        description: "professional_network.composer.regular_description",
        icon: "plus",
        condition: (component) => {
          const composer = component.composerModel;
          return (
            composer?.action === CREATE_TOPIC && composer.creatingLinkedInShare
          );
        },
        action: (composer) => {
          composer.set("creatingLinkedInShare", false);
          composer.notifyPropertyChange("category");
        },
      });

      api.customizeComposerText({
        actionTitle: (model) =>
          model.creatingLinkedInShare
            ? "professional_network.composer.action_title"
            : undefined,
        saveLabel: (model) =>
          model.creatingLinkedInShare
            ? "professional_network.composer.publish_label"
            : undefined,
        saveIcon: (model) =>
          model.creatingLinkedInShare ? "linkedin" : undefined,
      });
    });
  },
};
