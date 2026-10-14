import { fn } from "@ember/helper";
import { on } from "@ember/modifier";
import { eq } from "discourse/truth-helpers";

const PROJECT_STATUS_OPTIONS = [
  { value: "planned", label: "Planned" },
  { value: "active", label: "Active" },
  { value: "completed", label: "Completed" },
  { value: "paused", label: "Paused" },
];

const OrganizationProjects = <template>
  <fieldset
    class="professional-network-aspirations professional-network-review"
  >
    <legend>Projects</legend>
    <p>Show what the organization is working on and what people can expect next.</p>

    <div class="professional-network-services">
      {{#each @editor.profileData.organization_projects as |project index|}}
        <article
          class="professional-network-service-row professional-network-project-row"
        >
          <label class="is-wide">Project name
            <input
              placeholder="e.g. Regional founder programme"
              type="text"
              value={{project.name}}
              {{on
                "input"
                (fn @editor.changeEntry "organization_projects" index "name")
              }}
            />
          </label>
          <label class="is-wide">Description
            <textarea
              placeholder="What the project does, who it serves, and why it matters"
              rows="4"
              value={{project.description}}
              {{on
                "input"
                (fn
                  @editor.changeEntry
                  "organization_projects"
                  index
                  "description"
                )
              }}
            ></textarea>
          </label>
          <label>Status<select
              {{on
                "change"
                (fn @editor.changeEntry "organization_projects" index "status")
              }}
            >{{#each PROJECT_STATUS_OPTIONS as |statusOption|}}<option
                  selected={{eq project.status statusOption.value}}
                  value={{statusOption.value}}
                >{{statusOption.label}}</option>{{/each}}</select></label>
          <label>Start date<input
              type="date"
              value={{project.starts_on}}
              {{on
                "input"
                (fn
                  @editor.changeEntry "organization_projects" index "starts_on"
                )
              }}
            /></label>
          <label>End date<input
              type="date"
              value={{project.ends_on}}
              {{on
                "input"
                (fn @editor.changeEntry "organization_projects" index "ends_on")
              }}
            /></label>
          <label class="is-wide">What’s coming up next?
            <textarea
              placeholder="The next milestone, launch, event, or opportunity people can expect"
              rows="3"
              value={{project.upcoming}}
              {{on
                "input"
                (fn
                  @editor.changeEntry "organization_projects" index "upcoming"
                )
              }}
            ></textarea>
          </label>
          <button
            class="btn btn-flat"
            type="button"
            {{on
              "click"
              (fn @editor.removeEntry "organization_projects" index)
            }}
          >Remove project</button>
        </article>
      {{else}}
        <p>No projects added yet.</p>
      {{/each}}
      <button
        class="btn btn-default"
        type="button"
        {{on "click" (fn @editor.addEntry "organization_projects")}}
      >+ Add a project</button>
    </div>
  </fieldset>
</template>;

export default OrganizationProjects;
