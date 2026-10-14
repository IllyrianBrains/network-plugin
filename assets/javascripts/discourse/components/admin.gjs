import Component from "@glimmer/component";
import { tracked } from "@glimmer/tracking";
import { concat, fn } from "@ember/helper";
import { on } from "@ember/modifier";
import { action } from "@ember/object";
import { service } from "@ember/service";
import { ajax } from "discourse/lib/ajax";
import { eq } from "discourse/truth-helpers";

const EMPTY_CITY = {
  name: "",
  country: "",
  region: "",
  lat: "",
  lng: "",
  status: "active",
  region_color: "",
  image_url: "",
  luma_url: "",
  instagram_url: "",
  aliases: "",
  activities: "",
};

const LIST_FIELDS = ["aliases", "activities"];

export default class ProfessionalNetworkAdmin extends Component {
  @service currentUser;
  @service dialog;
  @service siteSettings;

  @tracked health = null;
  @tracked cities = [];
  @tracked city = { ...EMPTY_CITY };
  @tracked editingId = null;
  @tracked error = null;

  constructor() {
    super(...arguments);
    if (this.currentUser?.admin) {
      this.load();
    }
  }

  async load() {
    try {
      const [health, cityResponse] = await Promise.all([
        ajax("/network/admin/health"),
        ajax("/network/admin/cities"),
      ]);
      this.health = health;
      this.cities = cityResponse.cities || [];
    } catch {
      this.error = "Could not load network administration data.";
    }
  }

  @action
  changeCity(field, event) {
    this.city = { ...this.city, [field]: event.target.value };
  }

  @action
  editCity(city) {
    this.editingId = city.id;
    this.error = null;
    this.city = Object.fromEntries(
      Object.keys(EMPTY_CITY).map((field) => [
        field,
        LIST_FIELDS.includes(field)
          ? (city[field] || []).join(", ")
          : (city[field] ?? EMPTY_CITY[field]),
      ])
    );
  }

  @action
  cancelEdit() {
    this.editingId = null;
    this.error = null;
    this.city = { ...EMPTY_CITY };
  }

  @action
  async saveCity(event) {
    event.preventDefault();
    this.error = null;
    const city = { ...this.city, lat: this.city.lat || null, lng: this.city.lng || null };
    LIST_FIELDS.forEach((field) => {
      city[field] = this.city[field]
        .split(",")
        .map((value) => value.trim())
        .filter(Boolean);
    });
    const path = this.editingId
      ? `/network/admin/cities/${this.editingId}`
      : "/network/admin/cities";
    try {
      await ajax(path, {
        type: this.editingId ? "PUT" : "POST",
        data: { city },
      });
      this.cancelEdit();
      await this.load();
    } catch (error) {
      this.error =
        error?.jqXHR?.responseJSON?.errors?.join(" ") ||
        "Could not save the city.";
    }
  }

  @action
  async deleteCity(city) {
    const confirmed = await this.dialog.confirm({
      message: `Delete ${city.name}?`,
    });
    if (!confirmed) {
      return;
    }
    await ajax(`/network/admin/cities/${city.id}`, { type: "DELETE" });
    await this.load();
  }

  @action
  async mergeIntoEditedCity(city) {
    if (!this.editingId || city.id === this.editingId) {
      return;
    }
    const confirmed = await this.dialog.confirm({
      message: `Merge ${city.name} into the city being edited?`,
    });
    if (!confirmed) {
      return;
    }
    await ajax(`/network/admin/cities/${this.editingId}/merge`, {
      type: "POST",
      data: { source_id: city.id },
    });
    await this.load();
  }

  <template>
    <section class="professional-network-admin">
      <header><p class="professional-network-panel__eyebrow">{{this.siteSettings.professional_network_name}}</p><h2>Network administration</h2><p>Monitor profile health and manage
          the city directory.</p></header>
      {{#if this.currentUser.admin}}
        {{#if this.error}}<p
            class="professional-network-error"
          >{{this.error}}</p>{{/if}}
        {{#if this.health}}<section class="professional-network-admin__health">
            <h3>Network health</h3><dl>
              <div><dt>Profiles</dt><dd
                >{{this.health.profiles.total}}</dd></div>
              <div><dt>Published</dt><dd
                >{{this.health.profiles.published}}</dd></div>
              <div><dt>Stale</dt><dd>{{this.health.profiles.stale}}</dd></div>
              <div><dt>Pending imports</dt><dd
                >{{this.health.pending_imports}}</dd></div>
              <div><dt>Failed LinkedIn previews</dt><dd
                >{{this.health.failed_linkedin_previews}}</dd></div>
              <div><dt>Cities without coordinates</dt><dd
                >{{this.health.cities.missing_coordinates}}</dd></div>
              <div><dt>Broken organization links</dt><dd
                >{{this.health.broken_business_links}}</dd></div>
            </dl>
            <a
              class="btn btn-default"
              href="/network/directory/export"
            >Export directory CSV</a>
          </section>{{/if}}
        <section class="professional-network-admin__cities">
          <h3>Cities</h3>
          <form {{on "submit" this.saveCity}}>
            <p class="professional-network-admin__form-heading">{{if
                this.editingId
                (concat "Editing " this.city.name)
                "Add a city"
              }}</p>
            <div class="professional-network-admin__city-fields">
              <div class="professional-network-field">
                <label for="professional-network-admin-city-name">City
                  name</label>
                <input
                  id="professional-network-admin-city-name"
                  placeholder="Tirana"
                  required
                  type="text"
                  value={{this.city.name}}
                  {{on "input" (fn this.changeCity "name")}}
                />
              </div>
              <div class="professional-network-field">
                <label for="professional-network-admin-city-country">Country</label>
                <input
                  id="professional-network-admin-city-country"
                  placeholder="Albania"
                  required
                  type="text"
                  value={{this.city.country}}
                  {{on "input" (fn this.changeCity "country")}}
                />
              </div>
              <div class="professional-network-field">
                <label for="professional-network-admin-city-region">Region</label>
                <input
                  id="professional-network-admin-city-region"
                  placeholder="Optional, e.g. Balkans"
                  type="text"
                  value={{this.city.region}}
                  {{on "input" (fn this.changeCity "region")}}
                />
              </div>
              <div class="professional-network-field">
                <label for="professional-network-admin-city-status">Status</label>
                <select
                  id="professional-network-admin-city-status"
                  {{on "change" (fn this.changeCity "status")}}
                >
                  <option
                    selected={{eq this.city.status "active"}}
                    value="active"
                  >Active</option>
                  <option
                    selected={{eq this.city.status "paused"}}
                    value="paused"
                  >Paused</option>
                  <option
                    selected={{eq this.city.status "inactive"}}
                    value="inactive"
                  >Inactive</option>
                </select>
              </div>
              <div class="professional-network-field">
                <label for="professional-network-admin-city-lat">Latitude</label>
                <input
                  id="professional-network-admin-city-lat"
                  max="90"
                  min="-90"
                  placeholder="e.g. 41.3275"
                  step="any"
                  type="number"
                  value={{this.city.lat}}
                  {{on "input" (fn this.changeCity "lat")}}
                />
              </div>
              <div class="professional-network-field">
                <label for="professional-network-admin-city-lng">Longitude</label>
                <input
                  id="professional-network-admin-city-lng"
                  max="180"
                  min="-180"
                  placeholder="e.g. 19.8187"
                  step="any"
                  type="number"
                  value={{this.city.lng}}
                  {{on "input" (fn this.changeCity "lng")}}
                />
                <small>Latitude and longitude must be set together, or both left
                  blank.</small>
              </div>
              <div class="professional-network-field">
                <label for="professional-network-admin-city-color">Region
                  color</label>
                <input
                  id="professional-network-admin-city-color"
                  placeholder="#2563eb"
                  type="text"
                  value={{this.city.region_color}}
                  {{on "input" (fn this.changeCity "region_color")}}
                />
              </div>
              <div class="professional-network-field">
                <label for="professional-network-admin-city-image">Image URL</label>
                <input
                  id="professional-network-admin-city-image"
                  placeholder="https://…"
                  type="text"
                  value={{this.city.image_url}}
                  {{on "input" (fn this.changeCity "image_url")}}
                />
              </div>
              <div class="professional-network-field">
                <label for="professional-network-admin-city-luma">Luma URL</label>
                <input
                  id="professional-network-admin-city-luma"
                  placeholder="https://lu.ma/…"
                  type="text"
                  value={{this.city.luma_url}}
                  {{on "input" (fn this.changeCity "luma_url")}}
                />
              </div>
              <div class="professional-network-field">
                <label for="professional-network-admin-city-instagram">Instagram
                  URL</label>
                <input
                  id="professional-network-admin-city-instagram"
                  placeholder="https://instagram.com/…"
                  type="text"
                  value={{this.city.instagram_url}}
                  {{on "input" (fn this.changeCity "instagram_url")}}
                />
              </div>
              <div class="professional-network-field is-wide">
                <label for="professional-network-admin-city-aliases">Alternate
                  names</label>
                <input
                  id="professional-network-admin-city-aliases"
                  placeholder="Tirane, Tirana City"
                  type="text"
                  value={{this.city.aliases}}
                  {{on "input" (fn this.changeCity "aliases")}}
                />
                <small>Comma-separated. Lets members' free-text city entries
                  (e.g. "Tirane") match this city.</small>
              </div>
              <div class="professional-network-field is-wide">
                <label for="professional-network-admin-city-activities">Activities</label>
                <input
                  id="professional-network-admin-city-activities"
                  placeholder="Meetups, Coworking"
                  type="text"
                  value={{this.city.activities}}
                  {{on "input" (fn this.changeCity "activities")}}
                />
                <small>Comma-separated tags shown on the city's public
                  page.</small>
              </div>
            </div>
            {{#if this.error}}<p
                class="professional-network-field-error"
              >{{this.error}}</p>{{/if}}
            <div class="professional-network-admin__form-actions">
              <button class="btn btn-primary" type="submit">{{if
                  this.editingId
                  "Update city"
                  "Add city"
                }}</button>
              {{#if this.editingId}}<button
                  class="btn btn-flat"
                  type="button"
                  {{on "click" this.cancelEdit}}
                >Cancel</button>{{/if}}
            </div>
          </form>
          <div class="professional-network-admin__city-list">{{#each
              this.cities
              as |city|
            }}
              <article>
                <div>
                  <strong>{{city.name}}</strong>
                  <small>{{city.country}}
                    ·
                    {{city.status}}
                    {{#unless city.lat}}· missing coordinates{{/unless}}</small>
                </div>
                <button
                  class="btn btn-default"
                  type="button"
                  {{on "click" (fn this.editCity city)}}
                >Edit</button>
                {{#if this.editingId}}<button
                    class="btn btn-default"
                    disabled={{eq city.id this.editingId}}
                    type="button"
                    {{on "click" (fn this.mergeIntoEditedCity city)}}
                  >Merge into edited city</button>{{/if}}
                <button
                  class="btn btn-danger"
                  type="button"
                  {{on "click" (fn this.deleteCity city)}}
                >Delete</button>
              </article>
            {{else}}
              <p>No cities yet.</p>
            {{/each}}</div>
        </section>
      {{else}}<p>Administrator access is required.</p>{{/if}}
    </section>
  </template>
}
