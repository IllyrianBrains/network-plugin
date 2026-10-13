import Component from "@glimmer/component";
import { tracked } from "@glimmer/tracking";
import { on } from "@ember/modifier";
import { action } from "@ember/object";
import { ajax } from "discourse/lib/ajax";
import CategoryChooser from "discourse/select-kit/components/category-chooser";
import TagChooser from "discourse/select-kit/components/tag-chooser";
import { normalizeLinkedInShareUrl } from "discourse/plugins/discourse-professional-network/discourse/lib/linkedin-share";

export default class ProfessionalNetworkEditorShare extends Component {
  @tracked url = "";
  @tracked title = "";
  @tracked commentary = "";
  @tracked categoryId = null;
  @tracked tags = ["linkedin"];
  @tracked fetching = false;
  @tracked loading = false;
  @tracked error = null;
  @tracked result = null;

  @action
  updateUrl(event) {
    this.url = event.target.value;
    this.error = null;
  }

  @action
  updateTitle(event) {
    this.title = event.target.value;
  }

  @action
  updateCommentary(event) {
    this.commentary = event.target.value;
  }

  @action
  changeCategory(categoryId) {
    this.categoryId = categoryId;
  }

  @action
  changeTags(tags) {
    this.tags = tags;
  }

  @action
  pasteUrl(event) {
    const pasted = event.clipboardData?.getData("text/plain");
    if (pasted) {
      this.fetchPreview(pasted);
    }
  }

  @action
  blurUrl() {
    this.fetchPreview(this.url);
  }

  // Best-effort: pulls the post's own text (and any hashtags in it) via the
  // server's Oneboxer-backed preview so the member doesn't have to retype
  // what LinkedIn already shows. LinkedIn often hides most of a post from
  // logged-out requests, so this can come back empty -- the member can
  // always just write the commentary and tags themselves.
  async fetchPreview(rawUrl) {
    const normalized = normalizeLinkedInShareUrl(rawUrl);
    if (!normalized || this.fetching) {
      return;
    }

    this.fetching = true;
    try {
      const { text, tags } = await ajax("/network/linkedin-preview", {
        data: { url: normalized },
      });
      if (this.isDestroying) {
        return;
      }
      if (text && !this.commentary.trim()) {
        this.commentary = text;
      }
      if (tags?.length) {
        this.tags = Array.from(new Set([...this.tags, ...tags]));
      }
    } catch {
      // Best effort only; the member can still fill in the form by hand.
    } finally {
      if (!this.isDestroying) {
        this.fetching = false;
      }
    }
  }

  @action
  async submit(event) {
    event.preventDefault();
    if (this.loading) {
      return;
    }

    const normalized = normalizeLinkedInShareUrl(this.url);
    if (!normalized) {
      this.error =
        "That doesn’t look like a LinkedIn post link. Paste the URL of a specific post (linkedin.com/posts/… or /feed/update/…).";
      return;
    }
    if (!this.categoryId) {
      this.error = "Choose a category to post this in.";
      return;
    }
    if (!this.title.trim()) {
      this.error = "Add a topic title.";
      return;
    }

    this.loading = true;
    this.error = null;
    this.result = null;
    try {
      const result = await ajax("/network/shares", {
        type: "POST",
        data: {
          url: normalized,
          title: this.title.trim(),
          commentary: this.commentary.trim(),
          category_id: this.categoryId,
          tags: this.tags,
        },
      });
      if (this.isDestroying) {
        return;
      }
      this.result = result;
      this.url = "";
      this.title = "";
      this.commentary = "";
      this.tags = ["linkedin"];
    } catch (error) {
      if (this.isDestroying) {
        return;
      }
      this.error =
        error?.jqXHR?.responseJSON?.errors?.join(" ") ||
        error?.jqXHR?.responseJSON?.error ||
        error?.message ||
        "Could not share this post";
    } finally {
      if (!this.isDestroying) {
        this.loading = false;
      }
    }
  }

  <template>
    <div class="professional-network-share">
      <header class="professional-network-share__hero">
        <span
          aria-hidden="true"
          class="professional-network-share__mark"
        >in</span>
        <div>
          <p class="professional-network-panel__eyebrow">LinkedIn</p>
          <h1>Share post</h1>
          <p>Bring a useful LinkedIn post into the community and add the context
            people need to start a conversation.</p>
        </div>
      </header>

      <form
        class="professional-network-share__form"
        {{on "submit" this.submit}}
      >
        <section class="professional-network-share__card">
          <header>
            <span>1</span>
            <div>
              <h2>Add the post</h2>
              <p>Paste a link to a specific LinkedIn post.</p>
            </div>
          </header>
          <div class="professional-network-field">
            <label for="professional-network-share-url">LinkedIn post link</label>
            <input
              disabled={{this.loading}}
              id="professional-network-share-url"
              placeholder="https://www.linkedin.com/posts/…"
              type="url"
              value={{this.url}}
              {{on "input" this.updateUrl}}
              {{on "paste" this.pasteUrl}}
              {{on "blur" this.blurUrl}}
            />
            <small class="professional-network-share__hint">{{if
                this.fetching
                "Fetching post details…"
                "We’ll try to bring across the post text and hashtags."
              }}</small>
          </div>
        </section>

        <section class="professional-network-share__card">
          <header>
            <span>2</span>
            <div>
              <h2>Choose where it belongs</h2>
              <p>Help members understand and discover your post.</p>
            </div>
          </header>
          <div class="professional-network-share__grid">
            <div class="professional-network-field">
              <label for="professional-network-share-category">Category</label>
              <CategoryChooser
                @onChange={{this.changeCategory}}
                @value={{this.categoryId}}
              />
            </div>
            <div class="professional-network-field is-wide">
              <label for="professional-network-share-tags">Tags</label>
              <TagChooser
                @allowCreate={{true}}
                @onChange={{this.changeTags}}
                @tags={{this.tags}}
                @unlimitedTagCount={{true}}
              />
              <small>Hashtags found in the post appear here automatically. You
                can add or remove them.</small>
            </div>
          </div>
        </section>

        <section class="professional-network-share__card">
          <header>
            <span>3</span>
            <div>
              <h2>Add your perspective</h2>
              <p>Tell the community why this is worth discussing.</p>
            </div>
          </header>
          <div class="professional-network-field">
            <label for="professional-network-share-title">Topic title</label>
            <input
              disabled={{this.loading}}
              id="professional-network-share-title"
              placeholder="Add a clear, inviting title"
              required
              type="text"
              value={{this.title}}
              {{on "input" this.updateTitle}}
            />
          </div>
          <div class="professional-network-field">
            <label for="professional-network-share-commentary">Post text or
              commentary</label>
            <textarea
              disabled={{this.loading}}
              id="professional-network-share-commentary"
              placeholder="Add the key takeaway, a question, or your perspective…"
              rows="7"
              value={{this.commentary}}
              {{on "input" this.updateCommentary}}
            ></textarea>
          </div>
        </section>

        {{#if this.error}}
          <p class="professional-network-error" role="alert">{{this.error}}</p>
        {{/if}}
        {{#if this.result}}
          <p class="professional-network-success" role="status">Shared.
            <a href="/t/{{this.result.topic_id}}">View the new topic</a>.</p>
        {{/if}}

        <footer class="professional-network-share__actions">
          <p>Your post will be published as a new community topic.</p>
          <button
            class="btn btn-primary"
            disabled={{this.loading}}
            type="submit"
          >{{if this.loading "Sharing…" "Share post"}}</button>
        </footer>
      </form>
    </div>
  </template>
}
