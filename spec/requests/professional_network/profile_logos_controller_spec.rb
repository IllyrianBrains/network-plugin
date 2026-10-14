# frozen_string_literal: true

require "rails_helper"

RSpec.describe ProfessionalNetwork::ProfileLogosController do
  fab!(:user)

  describe "POST /network/profile/logo.json" do
    it "requires a signed-in member" do
      post "/network/profile/logo.json", params: { file: fixture_file_upload(file_from_fixtures("logo.png")) }

      expect(response.status).to eq(403)
    end

    it "404s when the member has no organization profile yet" do
      sign_in(user)

      post "/network/profile/logo.json", params: { file: fixture_file_upload(file_from_fixtures("logo.png")) }

      expect(response.status).to eq(404)
    end

    it "404s when the member only has a person profile" do
      sign_in(user)
      ProfessionalNetwork::Profile.create!(
        user: user, website_key: "default", profile_type: "person", public_profile: true,
        data: { "name" => "Ada" },
      )

      post "/network/profile/logo.json", params: { file: fixture_file_upload(file_from_fixtures("logo.png")) }

      expect(response.status).to eq(404)
    end

    context "with an organization profile" do
      let!(:profile) do
        ProfessionalNetwork::Profile.create!(
          user: user, website_key: "default", profile_type: "organization", public_profile: true,
          data: { "name" => "Acme" },
        )
      end

      it "rejects a non-image upload" do
        sign_in(user)

        post "/network/profile/logo.json",
             params: { file: fixture_file_upload(file_from_fixtures("fake.not_image", "images")) }

        expect(response.status).to eq(400)
        expect(profile.reload.logo_upload_id).to be_nil
      end

      it "stores the upload and writes logo_url onto the profile" do
        sign_in(user)

        post "/network/profile/logo.json", params: { file: fixture_file_upload(file_from_fixtures("logo.png")) }

        expect(response.status).to eq(200)
        expect(response.parsed_body["logo_url"]).to be_present
        profile.reload
        expect(profile.logo_upload).to be_present
        expect(profile.data["logo_url"]).to eq(response.parsed_body["logo_url"])
      end
    end
  end
end
