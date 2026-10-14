# frozen_string_literal: true

require "rails_helper"

RSpec.describe ProfessionalNetwork::Mentoring::ProfileMatch do
  fab!(:seeker_user, :user)
  fab!(:mentor_user, :user)

  let(:seeker_profile) do
    ProfessionalNetwork::Profile.new(user: seeker_user, data: {})
  end
  let(:mentor_profile) do
    ProfessionalNetwork::Profile.new(
      user: mentor_user,
      data: { "fields_of_expertise" => ["Engineering Leadership"] },
    )
  end

  before do
    ProfessionalNetwork::Mentoring::Preferences.new(seeker_user).assign(
      "mentoring_interests" => ["mentor_connection"],
    )
    ProfessionalNetwork::Mentoring::Preferences.new(mentor_user).assign(
      "mentoring_interests" => ["mentoring_opportunity"],
    )
  end

  it "returns a reason for complementary intent in the target field" do
    reasons = described_class.new(
      seeker_profile,
      mentor_profile,
      target_field: "Engineering Leadership",
    ).reasons

      expect(reasons).to eq(
        [{ weight: 6, category: "mentoring", label: "Open to mentoring in Engineering Leadership" }],
      )
  end

  it "returns no reason when the candidate does not work in the target field" do
    reasons = described_class.new(seeker_profile, mentor_profile, target_field: "Medicine").reasons

    expect(reasons).to eq([])
  end
end
