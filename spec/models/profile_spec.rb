# frozen_string_literal: true

require "rails_helper"

RSpec.describe ProfessionalNetwork::Profile do
  fab!(:user)

  it "supports person and organization profile types" do
    expect(described_class::PROFILE_TYPES).to contain_exactly("person", "organization")
  end

  it "does not allow a saved profile to change type" do
    profile = described_class.create!(
      user: user,
      website_key: "example.com",
      profile_type: "person",
      data: {},
      public_profile: false
    )

    profile.profile_type = "organization"

    expect(profile).not_to be_valid
    expect(profile.errors[:profile_type]).to include("cannot be changed")
  end
end
