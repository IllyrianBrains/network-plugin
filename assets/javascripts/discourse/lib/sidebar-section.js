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
  },
  {
    name: "professional-network-recommendations",
    route: "professional-network-recommendations",
    titleKey: "professional_network.recommendations.title",
    icon: "user-plus",
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
  },
  {
    name: "professional-network-share",
    route: "professional-network-share",
    titleKey: "professional_network.share_page.title",
    icon: "fab-linkedin-in",
  },
];

// Registered via api.addSidebarSection so these render as their own always-visible
// section (like Categories/Tags), instead of api.addCommunitySectionLink's "More…"
// drawer, which has no admin "Customize" entry and can't be pinned visible by users.
export default function buildProfessionalNetworkSidebarSection(
  BaseCustomSidebarSection,
  BaseCustomSidebarSectionLink
) {
  class ProfessionalNetworkSectionLink extends BaseCustomSidebarSectionLink {
    constructor(link) {
      super();
      this.link = link;
    }

    get name() {
      return this.link.name;
    }

    get route() {
      return this.link.route;
    }

    get title() {
      return i18n(this.link.titleKey);
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
  }

  return class ProfessionalNetworkSidebarSection extends BaseCustomSidebarSection {
    get name() {
      return "professional-network";
    }

    get text() {
      return i18n("professional_network.sidebar_section.title");
    }

    get links() {
      return SECTION_LINKS.map(
        (link) => new ProfessionalNetworkSectionLink(link)
      );
    }
  };
}
