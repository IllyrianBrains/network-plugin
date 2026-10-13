import { fn } from "@ember/helper";
import { on } from "@ember/modifier";

const OrganizationContact = <template>
  <fieldset
    class="professional-network-aspirations professional-network-review"
  >
    <legend>Links & contact</legend><p>Add the public links members can use to
      learn more or get in touch.</p>
    <details class="professional-network-form-section" open><summary><span
        >Public links</span></summary><div
        class="professional-network-form-section__body"
      >
        <div class="professional-network-field"><label
            for="professional-network-organization-website"
          >Website</label><input
            id="professional-network-organization-website"
            placeholder="https://example.com"
            type="url"
            value={{@editor.profileData.website}}
            {{on "input" (fn @editor.changeProfileField "website")}}
          /></div>
        <div class="professional-network-field"><label
            for="professional-network-organization-linkedin"
          >LinkedIn</label><input
            id="professional-network-organization-linkedin"
            placeholder="https://www.linkedin.com/company/…"
            type="url"
            value={{@editor.profileData.linkedin_url}}
            {{on "input" (fn @editor.changeProfileField "linkedin_url")}}
          /></div>
        <div class="professional-network-field"><label
            for="professional-network-organization-instagram"
          >Instagram</label><input
            id="professional-network-organization-instagram"
            placeholder="https://www.instagram.com/…"
            type="url"
            value={{@editor.profileData.instagram_url}}
            {{on "input" (fn @editor.changeProfileField "instagram_url")}}
          /></div>
        <div class="professional-network-field"><label
            for="professional-network-organization-logo"
          >Logo URL</label><input
            id="professional-network-organization-logo"
            placeholder="https://example.com/logo.png"
            type="url"
            value={{@editor.profileData.logo_url}}
            {{on "input" (fn @editor.changeProfileField "logo_url")}}
          /><small>Use a public HTTPS image URL.</small></div>
        <div class="professional-network-field"><label
            for="professional-network-organization-portfolio"
          >Portfolio</label><input
            id="professional-network-organization-portfolio"
            type="url"
            value={{@editor.profileData.portfolio_url}}
            {{on "input" (fn @editor.changeProfileField "portfolio_url")}}
          /></div>
        <div class="professional-network-field"><label
            for="professional-network-organization-calendar"
          >Booking link</label><input
            id="professional-network-organization-calendar"
            type="url"
            value={{@editor.profileData.calendar_url}}
            {{on "input" (fn @editor.changeProfileField "calendar_url")}}
          /></div>
        <div class="professional-network-field is-wide"><label
            for="professional-network-organization-contact"
          >Public contact link</label><input
            id="professional-network-organization-contact"
            placeholder="Contact form or other public contact page"
            type="url"
            value={{@editor.profileData.contact_url}}
            {{on "input" (fn @editor.changeProfileField "contact_url")}}
          /></div>
      </div></details>
  </fieldset>
</template>;

export default OrganizationContact;
