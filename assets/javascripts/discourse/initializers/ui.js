import { withPluginApi } from "discourse/lib/plugin-api";
import buildProfessionalNetworkSidebarSection from "discourse/plugins/discourse-professional-network/discourse/lib/sidebar-section";

const COLOR_SETTINGS = {
  professional_network_color: "--pn-site-color",
  professional_network_profile_label_color: "--pn-profile-label-color",
  professional_network_linkedin_color: "--pn-site-linkedin-color",
  professional_network_background_color: "--pn-site-background-color",
  professional_network_card_color: "--pn-site-card-color",
  professional_network_border_color: "--pn-site-border-color",
};

function applyNetworkColors(siteSettings) {
  for (const [setting, property] of Object.entries(COLOR_SETTINGS)) {
    const configuredColor = siteSettings[setting];
    const color = configuredColor.startsWith("#")
      ? configuredColor
      : `#${configuredColor}`;

    document.documentElement.style.setProperty(property, color);
  }

  if (siteSettings.professional_network_auto_contrast) {
    setContrastColor(
      "--pn-accent-contrast",
      siteSettings.professional_network_color
    );
    setContrastColor(
      "--pn-linkedin-contrast",
      siteSettings.professional_network_linkedin_color
    );
  }
}

function setContrastColor(property, configuredColor) {
  const rawHex = configuredColor.replace("#", "");
  const hex =
    rawHex.length === 3
      ? rawHex
          .split("")
          .map((value) => `${value}${value}`)
          .join("")
      : rawHex;
  const channels = [0, 2, 4].map((offset) =>
    Number.parseInt(hex.slice(offset, offset + 2), 16)
  );
  const luminance = channels.reduce(
    (sum, channel, index) => sum + channel * [0.299, 0.587, 0.114][index],
    0
  );
  document.documentElement.style.setProperty(
    property,
    luminance > 160 ? "#111111" : "#ffffff"
  );
}

export default {
  name: "professional-network-ui",

  initialize(owner) {
    const siteSettings = owner.lookup("service:site-settings");
    applyNetworkColors(siteSettings);

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

      api.addSidebarSection((BaseSection, BaseLink) =>
        buildProfessionalNetworkSidebarSection(
          siteSettings,
          BaseSection,
          BaseLink
        )
      );
    });
  },
};
