# frozen_string_literal: true

require "rails_helper"

RSpec.describe "Member network administration" do
  describe "GET /network/admin/health.json" do
    it "rejects a regular member" do
      sign_in(Fabricate(:user))

      get "/network/admin/health.json"

      expect(response.status).to eq(403)
    end

    it "requires an administrator rather than a moderator" do
      sign_in(Fabricate(:moderator))

      get "/network/admin/health.json"

      expect(response.status).to eq(403)
    end

    it "allows an administrator" do
      sign_in(Fabricate(:admin))

      get "/network/admin/health.json"

      expect(response.status).to eq(200)
      expect(response.parsed_body).to include("profiles", "cities")
    end
  end

  describe "POST /network/admin/cities.json" do
    it "requires an administrator rather than a moderator" do
      sign_in(Fabricate(:moderator))

      post "/network/admin/cities.json", params: { city: { name: "Tirana", country: "Albania" } }

      expect(response.status).to eq(403)
    end

    it "allows an administrator to create a scoped city" do
      sign_in(Fabricate(:admin))

      post "/network/admin/cities.json", params: { city: { name: "Tirana", country: "Albania" } }

      expect(response.status).to eq(201)
      city = ProfessionalNetwork::City.find(response.parsed_body.dig("city", "id"))
      expect(city.website_key).to eq("default")
    end
  end
end
