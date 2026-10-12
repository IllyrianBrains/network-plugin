# Illyrian Brains Community theme

A lightweight Discourse theme derived from the design tokens and interface
patterns in `../website/src/styles/base.css`.

It intentionally does not copy Astro component selectors. It restyles native
Discourse surfaces so upgrades, keyboard navigation, mobile layouts, and plugin
outlets continue to work normally.

## Install on staging

1. Create a ZIP whose root contains `about.json` and the `common/` directory:

   ```bash
   cd theme
   zip -r ../illyrian-brains-community-theme.zip about.json common README.md
   ```

2. In Discourse, open **Admin → Customize → Themes**, choose **Install**, then
   upload the ZIP.
3. Select the bundled **Illyrian Brains** color scheme and set the theme as the
   staging site's default.
4. Configure the normal Discourse `logo` and `logo small` site settings with
   the Illyrian Brains assets. The theme does not embed a second copy of them.
5. Check the homepage, topic list, topic page, composer, search, user profile,
   admin login flow, and the Professional Network panel at desktop and mobile
   widths before enabling it in production.

For Git-based installation, publish `theme/` as its own repository (or a
subtree split) so `about.json` is at the repository root.

## Maintenance

The canonical shared values are documented at the top of `common/common.scss`.
When the website palette or typography changes, update those variables first.
Avoid importing the website stylesheet directly: its global `body`, `main`,
header, and component rules are built for Astro and would conflict with
Discourse's application shell.
