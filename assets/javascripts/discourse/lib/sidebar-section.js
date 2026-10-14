import { service } from "@ember/service";
import { i18n } from "discourse-i18n";

const SECTION_LINKS = [
  {
    name: "professional-network-graph",
    route: "professional-network-graph",
    titleKey: "professional_network.network_graph.title",
    icon: "diagram-project",
  },
  {
    name: "professional-network-directory",
    route: "professional-network-directory",
    titleKey: "professional_network.directory.title",
    icon: "users",
    locked: true,
  },
  {
    name: "professional-network-recommendations",
    route: "professional-network-recommendations",
    titleKey: "professional_network.recommendations.title",
    icon: "user-plus",
    locked: true,
  },
  {
    name: "professional-network-organizations",
    route: "professional-network-organizations",
    titleKey: "professional_network.organization_directory.title",
    icon: "building",
  },
  {
    name: "professional-network-profile",
    route: "professional-network-profile",
    titleKey: "professional_network.profile_page.title",
    icon: "address-card",
    locked: true,
  },
  {
    name: "professional-network-share",
    route: "professional-network-share",
    titleKey: "professional_network.share_page.title",
    icon: "fab-linkedin-in",
    locked: true,
  },
];

// Registered via api.addSidebarSection so these render as their own always-visible
// section (like Categories/Tags), instead of api.addCommunitySectionLink's "More…"
// drawer, which has no admin "Customize" entry and can't be pinned visible by users.
export default function buildProfessionalNetworkSidebarSection(
  siteSettings,
  BaseCustomSidebarSection,
  BaseCustomSidebarSectionLink
) {
  class ProfessionalNetworkSectionLink extends BaseCustomSidebarSectionLink {
    // Link instances aren't instantiated via the container (unlike the
    // section itself, which gets `setOwner`'d by the sidebar renderer), so
    // `@service` can't resolve here -- the section reads `currentUser` and
    // passes the already-resolved boolean down instead.
    constructor(link, loggedIn) {
      super();
      this.link = link;
      this.loggedIn = loggedIn;
    }

    get name() {
      return this.link.name;
    }

    get route() {
      return this.link.route;
    }

    get title() {
      return this.locked
        ? `${i18n(this.link.titleKey)} (requires login)`
        : i18n(this.link.titleKey);
    }

    get text() {
      return i18n(this.link.titleKey);
    }

    get prefixType() {
      return "icon";
    }

    get prefixValue() {
      return this.link.icon;
    }

    get locked() {
      return Boolean(this.link.locked && !this.loggedIn);
    }

    get prefixBadge() {
      return this.locked ? "lock" : undefined;
    }
  }

  return class ProfessionalNetworkSidebarSection extends BaseCustomSidebarSection {
    @service currentUser;

    get name() {
      return "professional-network";
    }

    get text() {
      return siteSettings.professional_network_name;
    }

    get links() {
      const loggedIn = Boolean(this.currentUser);
      return SECTION_LINKS.map(
        (link) => new ProfessionalNetworkSectionLink(link, loggedIn)
      );
    }
  };
}
