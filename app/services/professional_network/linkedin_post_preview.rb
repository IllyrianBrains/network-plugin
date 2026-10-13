# frozen_string_literal: true

module ProfessionalNetwork
  # Pulls a best-effort snapshot of a shared LinkedIn post via Discourse's own
  # Oneboxer (the same fetch/caching/FinalDestination pipeline used to render
  # link previews everywhere else) -- no LinkedIn API or credentials involved.
  # LinkedIn frequently withholds full post content from logged-out requests,
  # so the text is often a short snippet (or missing entirely) and hashtags
  # near the end of a post may not appear at all; callers must treat both as
  # optional and let the member fill in the gaps themselves.
  class LinkedinPostPreview
    HASHTAG = /#([[:alpha:]][\w-]{0,49})/

    def self.fetch(url)
      normalized = SharedPost.normalize_url(url)
      return unless normalized

      html = Oneboxer.onebox(normalized)
      return if html.blank?

      body = Nokogiri::HTML5.fragment(html).at_css(".onebox-body")
      return unless body

      title = body.at_css("h3, h4")&.text&.squish
      description = body.at_css("p")&.text&.squish
      text = description.presence || title.presence
      return unless text

      combined = [title, description].compact.join(" ")
      { text: text, tags: hashtags_in(combined) }
    end

    def self.hashtags_in(text)
      text.scan(HASHTAG).flatten.map(&:downcase).uniq.first(10)
    end
  end
end
