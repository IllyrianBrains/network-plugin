# frozen_string_literal: true

require "rails_helper"

RSpec.describe ProfessionalNetwork::ProfilesController do
  fab!(:user)

  before do
    ProfessionalNetwork::Profile.create!(
      user: user,
      website_key: "default",
      public_profile: true,
      data: { "name" => "Ada", "industry" => "Technology" },
    )
  end

  describe "GET /network/profiles.json" do
    it "requires a signed-in member for the default (person) directory" do
      get "/network/profiles.json"

      expect(response.status).to eq(403)
    end

    it "does not require login for the public organizations directory" do
      get "/network/profiles.json", params: { profile_type: "organization" }

      expect(response.status).to eq(200)
    end

    it "returns pagination metadata and applies directory filters" do
      sign_in(user)

      get "/network/profiles.json", params: { industry: "tech", page: 1 }

      expect(response.status).to eq(200)
      expect(response.parsed_body["profiles"].length).to eq(1)
      expect(response.parsed_body["pagination"]).to include(
        "page" => 1, "per_page" => 25, "total_count" => 1,
      )
    end

    it "does not expose profiles from another website" do
      other_user = Fabricate(:user)
      ProfessionalNetwork::Profile.create!(
        user: other_user,
        website_key: "other",
        public_profile: true,
        data: { "name" => "Other Site" },
      )
      sign_in(user)

      get "/network/profiles.json"

      usernames = response.parsed_body["profiles"].map { |profile| profile["username"] }
      expect(usernames).to contain_exactly(user.username)
    end
  end

  describe "GET /network/directory/export.json" do
    it "rejects a regular member" do
      sign_in(user)

      get "/network/directory/export.json"

      expect(response.status).to eq(403)
    end

    it "rejects a moderator" do
      sign_in(Fabricate(:moderator))

      get "/network/directory/export.json"

      expect(response.status).to eq(403)
    end

    it "allows an admin to export" do
      sign_in(Fabricate(:admin))

      get "/network/directory/export.json"

      expect(response.status).to eq(200)
      expect(response.media_type).to eq("text/csv")
    end
  end

  describe "POST /network/profiles/:username/verify.json" do
    fab!(:org_owner, :user)

    let!(:organization) do
      ProfessionalNetwork::Profile.create!(
        user: org_owner, website_key: "default", profile_type: "organization", public_profile: true,
        data: { "name" => "Acme" },
      )
    end

    it "rejects a regular member" do
      sign_in(user)

      post "/network/profiles/#{org_owner.username}/verify.json"

      expect(response.status).to eq(403)
      expect(organization.reload.verified_at).to be_nil
    end

    it "rejects verifying a person profile" do
      sign_in(Fabricate(:admin))

      post "/network/profiles/#{user.username}/verify.json"

      expect(response.status).to eq(400)
    end

    it "lets staff verify an organization profile" do
      admin = Fabricate(:admin)
      sign_in(admin)

      post "/network/profiles/#{org_owner.username}/verify.json"

      expect(response.status).to eq(200)
      organization.reload
      expect(organization.verified_at).to be_present
      expect(organization.verified_by_id).to eq(admin.id)
    end
  end
end
