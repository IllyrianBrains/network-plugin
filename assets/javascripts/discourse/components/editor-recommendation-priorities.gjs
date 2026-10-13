import { fn } from "@ember/helper";
import { on } from "@ember/modifier";
import dIcon from "discourse/ui-kit/helpers/d-icon";

const ProfessionalNetworkEditorRecommendationPriorities = <template>
  <fieldset
    class="professional-network-aspirations professional-network-recommendation-preferences professional-network-review"
  >
    <legend>People recommendations</legend>

    <details
      class="professional-network-form-section"
      open={{@editor.sectionsExpanded}}
    >
      <summary><span>Ranking priorities</span><small>Use the arrows to set what
          matters most on the People to meet page</small></summary>
      <div class="professional-network-form-section__body is-wide">
        <ol class="professional-network-priority-list">
          {{#each @editor.recommendationPriorityItems as |item|}}
            <li>
              <span
                class="professional-network-priority-list__rank"
              >{{item.rank}}</span>
              <div>
                <strong>{{item.title}}</strong>
                <small>{{item.description}}</small>
              </div>
              <div class="professional-network-priority-list__actions">
                <button
                  aria-label="Move {{item.title}} up"
                  class="btn btn-icon"
                  disabled={{item.first}}
                  type="button"
                  {{on
                    "click"
                    (fn @editor.moveRecommendationPriority item.key -1)
                  }}
                >{{dIcon "arrow-up"}}</button>
                <button
                  aria-label="Move {{item.title}} down"
                  class="btn btn-icon"
                  disabled={{item.last}}
                  type="button"
                  {{on
                    "click"
                    (fn @editor.moveRecommendationPriority item.key 1)
                  }}
                >{{dIcon "arrow-down"}}</button>
              </div>
            </li>
          {{/each}}
        </ol>
      </div>
    </details>
  </fieldset>
</template>;

export default ProfessionalNetworkEditorRecommendationPriorities;
