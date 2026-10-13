# frozen_string_literal: true

require "rails_helper"

RSpec.describe ProfessionalNetwork::LinkedinPostPreview do
  describe ".fetch" do
    it "returns nil for a URL that isn't a LinkedIn post link" do
      expect(described_class.fetch("https://example.com/posts/123")).to be_nil
    end

    it "returns nil when Oneboxer has nothing to show" do
      allow(Oneboxer).to receive(:onebox).and_return("")

      expect(
        described_class.fetch("https://www.linkedin.com/posts/jane_hello-activity-1"),
      ).to be_nil
    end

    it "extracts the description text and hashtags from the onebox preview markup" do
      allow(Oneboxer).to receive(:onebox).and_return(
        '<aside class="onebox allowlistedgeneric"><article class="onebox-body">' \
          '<h3><a href="https://www.linkedin.com/posts/jane_hello-activity-1">Jane Doe on LinkedIn</a></h3>' \
          "<p>Excited to share this update! #hiring #RemoteWork</p>" \
          "</article></aside>",
      )

      result = described_class.fetch("https://www.linkedin.com/posts/jane_hello-activity-1")
      expect(result[:text]).to eq("Excited to share this update! #hiring #RemoteWork")
      expect(result[:tags]).to eq(%w[hiring remotework])
    end

    it "falls back to the title when there is no description" do
      allow(Oneboxer).to receive(:onebox).and_return(
        '<aside class="onebox allowlistedgeneric"><article class="onebox-body">' \
          '<h3><a href="https://www.linkedin.com/posts/jane_hello-activity-1">Jane Doe on LinkedIn</a></h3>' \
          "</article></aside>",
      )

      result = described_class.fetch("https://www.linkedin.com/posts/jane_hello-activity-1")
      expect(result[:text]).to eq("Jane Doe on LinkedIn")
      expect(result[:tags]).to eq([])
    end
  end
end
