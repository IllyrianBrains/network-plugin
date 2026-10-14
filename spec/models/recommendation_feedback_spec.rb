# frozen_string_literal: true

require "rails_helper"

RSpec.describe ProfessionalNetwork::RecommendationFeedback do
  fab!(:user)
  fab!(:recommended_user, :user)

  it "allows one scoped feedback record for a recommended member" do
    described_class.create!(
      website_key: "default", user: user, recommended_user: recommended_user,
    )
    duplicate = described_class.new(
      website_key: "default", user: user, recommended_user: recommended_user,
    )

    expect(duplicate).not_to be_valid
  end

  it "does not allow feedback about the same member" do
    feedback = described_class.new(
      website_key: "default", user: user, recommended_user: user,
    )

    expect(feedback).not_to be_valid
  end
end
