# frozen_string_literal: true

require "rails_helper"

# AGENTS.md calls this out explicitly: SiteSetting.professional_network_enabled
# must gate every request via BaseController#ensure_enabled (and, separately,
# requires_plugin on each controller), regardless of who's asking. These hit a
# representative controller from each group -- plain data, page shell, and
# admin -- rather than every route, since they all share the same two gates.
RSpec.describe "Professional network plugin disabled" do
  before { SiteSetting.professional_network_enabled = false }

  it "404s the public profiles directory" do
    get "/network/profiles.json"

    expect(response.status).to eq(404)
  end

  it "404s the network graph" do
    get "/network/network-graph.json"

    expect(response.status).to eq(404)
  end

  it "404s the city directory" do
    get "/network/cities.json"

    expect(response.status).to eq(404)
  end

  it "404s posting a LinkedIn share even for a signed-in member" do
    sign_in(Fabricate(:user))

    post "/network/shares.json", params: { url: "https://www.linkedin.com/posts/example" }

    expect(response.status).to eq(404)
  end

  it "404s admin endpoints even for an administrator" do
    sign_in(Fabricate(:admin))

    get "/network/admin/health.json"

    expect(response.status).to eq(404)
  end

  it "serves the directory again once re-enabled" do
    SiteSetting.professional_network_enabled = true

    get "/network/cities.json"

    expect(response.status).to eq(200)
  end
end
