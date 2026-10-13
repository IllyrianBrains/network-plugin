import Component from "@glimmer/component";
import { tracked } from "@glimmer/tracking";
import { on } from "@ember/modifier";
import { action } from "@ember/object";
import { modifier } from "ember-modifier";
import { ajax } from "discourse/lib/ajax";
import dIcon from "discourse/ui-kit/helpers/d-icon";
import loadOpenLayers from "discourse/plugins/discourse-professional-network/discourse/lib/load-openlayers";

/* global ol */

const DEFAULT_CENTER = [15, 44];

function bubbleStyle(feature, maxCount) {
  const cities = feature.get("features").map((item) => item.get("city"));
  const count = cities.reduce((sum, city) => sum + (city.member_count || 0), 0);
  const radius = 9 + Math.sqrt(count / Math.max(maxCount, 1)) * 18;

  return new ol.style.Style({
    image: new ol.style.Circle({
      radius,
      fill: new ol.style.Fill({ color: "rgba(27, 175, 122, 0.82)" }),
      stroke: new ol.style.Stroke({
        color: cities.length > 1 ? "#174f3d" : "#ffffff",
        width: 2,
      }),
    }),
    text: new ol.style.Text({
      text: String(count),
      fill: new ol.style.Fill({ color: "#ffffff" }),
      font: "600 12px sans-serif",
    }),
  });
}

export default class ProfessionalNetworkMap extends Component {
  @tracked loading = true;
  @tracked errored = false;
  @tracked cities = [];
  @tracked selectedCity = null;
  @tracked members = [];
  @tracked loadingMembers = false;
  map = null;

  load = modifier(() => {
    this.loadData();
  });

  setup = modifier((element) => {
    this.buildMap(element);
    return () => {
      this.map?.setTarget(null);
      this.map = null;
    };
  });

  async loadData() {
    try {
      const [, response] = await Promise.all([
        loadOpenLayers(),
        ajax("/network/cities/map"),
      ]);
      this.cities = (response.cities || []).filter(
        (city) =>
          Number.isFinite(Number(city.lat)) && Number.isFinite(Number(city.lng))
      );
    } catch {
      this.errored = true;
    } finally {
      this.loading = false;
    }
  }

  buildMap(element) {
    const maxCount = Math.max(
      ...this.cities.map((city) => city.member_count || 0),
      1
    );
    const features = this.cities.map((city) => {
      const feature = new ol.Feature({
        geometry: new ol.geom.Point(
          ol.proj.fromLonLat([Number(city.lng), Number(city.lat)])
        ),
        city,
      });
      return feature;
    });
    const source = new ol.source.Vector({ features });
    const clusterSource = new ol.source.Cluster({ distance: 42, source });

    this.map = new ol.Map({
      target: element,
      layers: [
        new ol.layer.Tile({ source: new ol.source.OSM() }),
        new ol.layer.Vector({
          source: clusterSource,
          style: (feature) => bubbleStyle(feature, maxCount),
        }),
      ],
      view: new ol.View({
        center: ol.proj.fromLonLat(DEFAULT_CENTER),
        zoom: 3,
      }),
    });

    if (features.length === 1) {
      this.map.getView().setCenter(features[0].getGeometry().getCoordinates());
      this.map.getView().setZoom(7);
    } else if (features.length > 1) {
      this.map.getView().fit(source.getExtent(), {
        padding: [45, 45, 45, 45],
        maxZoom: 7,
      });
    }

    this.map.on("singleclick", (event) => {
      const feature = this.map.forEachFeatureAtPixel(
        event.pixel,
        (item) => item
      );
      const cityFeatures = feature?.get("features") || [];
      if (cityFeatures.length === 1) {
        this.selectCity(cityFeatures[0].get("city"));
      } else if (cityFeatures.length > 1) {
        const extent = ol.extent.boundingExtent(
          cityFeatures.map((item) => item.getGeometry().getCoordinates())
        );
        this.map.getView().fit(extent, {
          duration: 300,
          padding: [70, 70, 70, 70],
          maxZoom: 9,
        });
      }
    });
    this.map.on("pointermove", (event) => {
      element.style.cursor = this.map.hasFeatureAtPixel(event.pixel)
        ? "pointer"
        : "";
    });
  }

  @action
  async selectCity(city) {
    this.selectedCity = city;
    this.members = [];
    this.loadingMembers = true;
    try {
      const response = await ajax(
        `/network/cities/${encodeURIComponent(city.slug)}`
      );
      this.members = response.members || [];
    } catch {
      this.members = [];
    } finally {
      this.loadingMembers = false;
    }
  }

  @action
  closeCity() {
    this.selectedCity = null;
    this.members = [];
  }

  <template>
    <section class="professional-network-map" {{this.load}}>
      {{#if this.loading}}
        <div class="professional-network-graph__placeholder">
          {{dIcon "spinner" class="fa-spin"}}
          <p>Loading map…</p>
        </div>
      {{else if this.errored}}
        <div
          class="professional-network-graph__placeholder professional-network-graph__placeholder--error"
        >
          {{dIcon "triangle-exclamation"}}
          <p>Could not load the network map.</p>
        </div>
      {{else if this.cities.length}}
        <div class="professional-network-map__layout">
          <div
            aria-label="Map of professional-network cities"
            class="professional-network-map__canvas"
            role="application"
            {{this.setup}}
          ></div>
          {{#if this.selectedCity}}
            <aside aria-live="polite" class="professional-network-map__details">
              <button
                aria-label="Close city details"
                type="button"
                {{on "click" this.closeCity}}
              >&times;</button>
              <p class="professional-network-panel__eyebrow">City</p>
              <h3>{{this.selectedCity.name}}</h3>
              {{#if this.selectedCity.country}}<p
                >{{this.selectedCity.country}}</p>{{/if}}
              {{#if this.loadingMembers}}
                <p>Loading members…</p>
              {{else if this.members.length}}
                <ul>
                  {{#each this.members as |member|}}
                    <li>
                      <a href="/u/{{member.username}}/professional-profile">
                        {{#if
                          member.profile.name
                        }}{{member.profile.name}}{{else}}{{member.username}}{{/if}}
                      </a>
                      {{#if member.profile.headline}}<small
                        >{{member.profile.headline}}</small>{{/if}}
                    </li>
                  {{/each}}
                </ul>
              {{else}}
                <p>No public members are currently listed here.</p>
              {{/if}}
            </aside>
          {{/if}}
        </div>
        <p class="professional-network-graph__status">
          Bubble size reflects the number of public members in each city.
          Locations are city centres, not members’ exact positions.
        </p>
      {{else}}
        <div class="professional-network-graph__placeholder">
          {{dIcon "circle-info"}}
          <p>No cities with map coordinates yet.</p>
        </div>
      {{/if}}
    </section>
  </template>
}
