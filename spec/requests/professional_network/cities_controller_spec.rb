# frozen_string_literal: true

require "rails_helper"

RSpec.describe ProfessionalNetwork::CitiesController do
  let!(:city) { ProfessionalNetwork::City.create!(website_key: "default", name: "Tirana", lat: 41, lng: 19) }

  before do
    3.times do |i|
      ProfessionalNetwork::Profile.create!(
        user: Fabricate(:user), website_key: "default", public_profile: true,
        data: { "name" => "Member #{i}", "city" => "Tirana" },
      )
    end
  end

  describe "GET /network/cities/:slug.json" do
    it "caps the member list for anonymous visitors but reports the real total" do
      stub_const(ProfessionalNetwork::CitiesController, :PREVIEW_MEMBER_LIMIT, 1) do
        get "/network/cities/tirana.json"

        expect(response.status).to eq(200)
        expect(response.parsed_body["members"].length).to eq(1)
        expect(response.parsed_body["member_total_count"]).to eq(3)
        expect(response.parsed_body["member_limit"]).to eq(1)
      end
    end

    it "returns the full member list to a signed-in member" do
      stub_const(ProfessionalNetwork::CitiesController, :PREVIEW_MEMBER_LIMIT, 1) do
        sign_in(Fabricate(:user))

        get "/network/cities/tirana.json"

        expect(response.status).to eq(200)
        expect(response.parsed_body["members"].length).to eq(3)
        expect(response.parsed_body["member_limit"]).to be_nil
      end
    end
  end
end
