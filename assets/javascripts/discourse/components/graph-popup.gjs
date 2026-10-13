import Component from "@glimmer/component";
import { on } from "@ember/modifier";
import { modifier } from "ember-modifier";

export default class ProfessionalNetworkGraphPopup extends Component {
  position = modifier((element) => {
    const popup = this.args.popup;
    if (!popup) {
      return;
    }
    element.style.left = `${popup.left}px`;
    element.style.top = `${popup.top}px`;
  });

  <template>
    {{#if @popup}}
      <div class="professional-network-graph__popup" {{this.position}}>
        <button
          aria-label="Close"
          class="professional-network-graph__popup-close"
          type="button"
          {{on "click" @onClose}}
        >&times;</button>
        <p
          class="professional-network-graph__popup-kind"
        >{{@popup.kindLabel}}</p>
        <h4
          class="professional-network-graph__popup-title"
        >{{@popup.title}}</h4>
        <ul class="professional-network-graph__popup-meta">
          {{#each @popup.meta as |line|}}
            <li>{{line}}</li>
          {{/each}}
        </ul>
        {{#if @popup.profileUrl}}
          <a
            class="professional-network-graph__popup-link"
            href={{@popup.profileUrl}}
          >Open profile ↗</a>
        {{/if}}
      </div>
    {{/if}}
  </template>
}
