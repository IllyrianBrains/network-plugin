# frozen_string_literal: true

require "rails_helper"

RSpec.describe ProfessionalNetwork::SharesController do
  fab!(:user)

  describe "POST /network/shares.json" do
    it "requires a signed-in member" do
      post "/network/shares.json", params: { url: "https://www.linkedin.com/posts/example" }

      expect(response.status).to eq(403)
    end

    # These are all attempts to smuggle a non-LinkedIn destination past the
    # host/path allowlist in SharesController#create -- a lookalike host, an
    # embedded-credential bypass of the host check, and a scheme that isn't
    # even http(s).
    [
      ["a host that merely contains linkedin.com", "https://linkedin.com.evil.example/posts/123"],
      ["a host that isn't linkedin.com at all", "https://evil.example/posts/123"],
      ["userinfo credentials in front of an otherwise-valid host", "https://attacker@www.linkedin.com/posts/123"],
      ["a path outside posts/feed-update", "https://www.linkedin.com/in/someone"],
      ["a non-http(s) scheme", "javascript:alert(1)"],
    ].each do |description, url|
      it "rejects #{description}" do
        sign_in(user)

        post "/network/shares.json", params: { url: url }

        expect(response.status).to eq(400)
        expect(ProfessionalNetwork::SharedPost.where(user_id: user.id)).to be_empty
      end
    end
  end
end
