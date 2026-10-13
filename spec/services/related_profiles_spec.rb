# frozen_string_literal: true

require "rails_helper"

RSpec.describe ProfessionalNetwork::RelatedProfiles do
  fab!(:mentee_user, :user)
  fab!(:mentor_user, :user)
  fab!(:peer_user, :user)
  fab!(:stranger_user, :user)

  def set_aspirations(user, attrs)
    aspirations = ProfessionalNetwork::Aspirations.new(user)
    aspirations.assign(attrs)
    aspirations.save!
  end

  let!(:mentee_profile) do
    set_aspirations(mentee_user, "field" => "Engineering Leadership", "mentoring_interests" => ["mentor_connection"])
    ProfessionalNetwork::Profile.create!(user: mentee_user, website_key: "default", public_profile: true, data: {})
  end
  let!(:mentor_profile) do
    set_aspirations(mentor_user, "mentoring_interests" => ["mentoring_opportunity"])
    ProfessionalNetwork::Profile.create!(
      user: mentor_user, website_key: "default", public_profile: true,
      data: { "fields_of_expertise" => ["Engineering Leadership"] },
    )
  end
  let!(:peer_profile) do
    set_aspirations(peer_user, "mentoring_interests" => ["mentor_connection"])
    ProfessionalNetwork::Profile.create!(
      user: peer_user, website_key: "default", public_profile: true,
      data: { "fields_of_expertise" => ["Engineering Leadership"] },
    )
  end
  let!(:stranger_profile) do
    ProfessionalNetwork::Profile.create!(
      user: stranger_user, website_key: "default", public_profile: true,
      data: { "city" => "Rome", "fields_of_expertise" => ["marketing"] },
    )
  end

  it "surfaces a complementary mentoring reason when the candidate works in the target field and offers mentoring" do
    match = described_class.new(mentee_profile).results.find { |r| r[:profile].id == mentor_profile.id }

    expect(match).to be_present
    expect(match[:reasons]).to include("Open to mentoring in Engineering Leadership")
  end

  it "does not surface the mentoring reason when the candidate works in the field but is only seeking, not offering" do
    match = described_class.new(mentee_profile).results.find { |r| r[:profile].id == peer_profile.id }

    expect(match[:reasons]).not_to include(a_string_matching(/mentoring/i))
  end

  it "excludes profiles with no shared city, field, skill or aspiration" do
    results = described_class.new(mentee_profile).results
    expect(results.map { |r| r[:profile].id }).not_to include(stranger_profile.id)
  end

  it "falls back to other published members when there are no strong matches" do
    mentee_profile.update!(data: {})
    mentor_profile.update!(data: {})
    peer_profile.update!(data: {})

    set_aspirations(mentee_user, "field" => "", "mentoring_interests" => [])
    set_aspirations(mentor_user, "mentoring_interests" => [])
    set_aspirations(peer_user, "mentoring_interests" => [])

    results = described_class.new(mentee_profile).results

    expect(results).not_to be_empty
    expect(results).to all(include(score: 0.0, reasons: ["Expand your professional network"]))
  end

  it "matches a job seeker with someone hiring" do
    set_aspirations(mentee_user, "business_interests" => ["job_opportunities"])
    set_aspirations(stranger_user, "business_interests" => ["hiring_candidates"])

    match = described_class.new(mentee_profile).results.find { |result| result[:profile].id == stranger_profile.id }

    expect(match[:score]).to be >= 6
    expect(match[:reasons]).to include("Looking for candidates")
  end

  it "matches someone seeking funding with a potential investor" do
    set_aspirations(mentee_user, "business_interests" => ["project_funding"])
    set_aspirations(stranger_user, "business_interests" => ["investment_opportunities"])

    match = described_class.new(mentee_profile).results.find { |result| result[:profile].id == stranger_profile.id }

    expect(match[:reasons]).to include("Interested in investing")
  end

  it "matches what one member is looking for against what another can help with" do
    mentee_profile.update!(data: mentee_profile.data.merge("looking_for" => "Looking for fundraising advice"))
    stranger_profile.update!(data: stranger_profile.data.merge("can_help_with" => "I can offer fundraising introductions"))

    match = described_class.new(mentee_profile).results.find { |result| result[:profile].id == stranger_profile.id }

    expect(match).to be_present
    expect(match[:reasons]).to include(a_string_matching(/May be able to help with what you're looking for: fundraising/))
  end

  it "does not match on common words shared between looking_for and can_help_with" do
    mentee_profile.update!(data: mentee_profile.data.merge("looking_for" => "Looking for someone to connect with"))
    stranger_profile.update!(data: stranger_profile.data.merge("can_help_with" => "Happy to help with general career advice"))

    results = described_class.new(mentee_profile).results
    expect(results.map { |r| r[:profile].id }).not_to include(stranger_profile.id)
  end

  it "uses cosine similarity to surface similar professional profile text" do
    mentee_profile.update!(data: { "about" => "Robotics automation systems" })
    stranger_profile.update!(data: { "about" => "Robotics automation research" })

    match = described_class.new(mentee_profile).results.find { |result| result[:profile].id == stranger_profile.id }

    expect(match[:score]).to be_between(0, 100)
    expect(match[:reasons]).to include("Similar professional background")
  end

  it "uses the member's priority order when ranking candidates" do
    city_user = Fabricate(:user)
    city_profile = ProfessionalNetwork::Profile.create!(
      user: city_user,
      website_key: "default",
      public_profile: true,
      data: { "city" => "Berlin" },
    )
    mentee_profile.update!(data: { "city" => "Berlin", "fields_of_expertise" => ["Robotics"] })
    stranger_profile.update!(data: { "fields_of_expertise" => ["Robotics"] })

    set_aspirations(
      mentee_user,
      "recommendation_priorities" => %w[location help mentoring opportunities background career],
    )
    results = described_class.new(mentee_profile).results

    expect(results.index { |result| result[:profile] == city_profile })
      .to be < results.index { |result| result[:profile] == stranger_profile }
  end
end
