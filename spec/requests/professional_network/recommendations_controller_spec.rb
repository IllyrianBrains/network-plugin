# frozen_string_literal: true

require "rails_helper"

RSpec.describe ProfessionalNetwork::RecommendationsController do
  fab!(:user)
  fab!(:recommended_user, :user)

  before do
    ProfessionalNetwork::Profile.create!(
      user: recommended_user,
      website_key: "default",
      public_profile: true,
      data: { "name" => "Hidden Member" },
    )
    ProfessionalNetwork::RecommendationFeedback.create!(
      website_key: "default",
      user: user,
      recommended_user: recommended_user,
      hidden: true,
    )
  end

  describe "GET /network/recommendations/hidden.json" do
    it "requires a signed-in member" do
      get "/network/recommendations/hidden.json"

      expect(response.status).to eq(403)
    end

    it "returns only the current member's hidden recommendations" do
      other_user = Fabricate(:user)
      ProfessionalNetwork::RecommendationFeedback.create!(
        website_key: "default",
        user: other_user,
        recommended_user: recommended_user,
        hidden: true,
      )
      sign_in(user)

      get "/network/recommendations/hidden.json"

      expect(response.status).to eq(200)
      expect(response.parsed_body["profiles"].map { |profile| profile["username"] })
        .to contain_exactly(recommended_user.username)
    end

    it "does not return feedback from another website" do
      ProfessionalNetwork::RecommendationFeedback.create!(
        website_key: "other",
        user: user,
        recommended_user: Fabricate(:user),
        hidden: true,
      )
      sign_in(user)

      get "/network/recommendations/hidden.json"

      expect(response.parsed_body["profiles"].length).to eq(1)
    end
  end
end
