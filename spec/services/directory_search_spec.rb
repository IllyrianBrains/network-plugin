# frozen_string_literal: true

require "rails_helper"

RSpec.describe ProfessionalNetwork::DirectorySearch do
  fab!(:freelancer_user) { Fabricate(:user) }
  fab!(:employee_user) { Fabricate(:user) }
  fab!(:organization_user) { Fabricate(:user) }
  fab!(:unpublished_user) { Fabricate(:user) }

  let!(:freelancer_profile) do
    ProfessionalNetwork::Profile.create!(
      user: freelancer_user, website_key: "default", public_profile: true,
      data: { "name" => "Freelancer", "availability" => "part_time", "open_to_consulting" => true,
               "services" => [{ "title" => "Logo design" }] },
    )
  end
  let!(:employee_profile) do
    ProfessionalNetwork::Profile.create!(
      user: employee_user, website_key: "default", public_profile: true,
      data: { "name" => "Employee", "availability" => "not_available", "open_to_consulting" => false },
    )
  end
  let!(:organization_profile) do
    ProfessionalNetwork::Profile.create!(
      user: organization_user, website_key: "default", public_profile: true,
      profile_type: "organization",
      data: { "name" => "Illyrian Brains Network", "organization_type" => "professional_network",
              "sector" => "Technology", "organization_needs" => ["Partners"],
              "collaboration_interests" => ["Joint research"],
              "organization_opportunity_details" => [{ "kind" => "mentoring", "title" => "Founder mentors" }] },
    )
  end

  let!(:unpublished_profile) do
    ProfessionalNetwork::Profile.create!(
      user: unpublished_user, website_key: "default", public_profile: false,
      data: { "name" => "Imported Network Member" },
    )
  end

  it "filters by availability" do
    results = described_class.new(website_key: "default", availability: "part_time").results
    expect(results.map(&:id)).to contain_exactly(freelancer_profile.id)
  end

  it "filters to only those open to consulting" do
    results = described_class.new(website_key: "default", open_to_consulting: true).results
    expect(results.map(&:id)).to contain_exactly(freelancer_profile.id)
  end

  it "does not filter by open_to_consulting when not requested" do
    results = described_class.new(website_key: "default").results
    expect(results.map(&:id)).to contain_exactly(freelancer_profile.id, employee_profile.id)
  end

  it "keeps unpublished network profiles out by default" do
    results = described_class.new(website_key: "default").results

    expect(results.map(&:id)).not_to include(unpublished_profile.id)
  end

  it "includes unpublished network profiles when explicitly requested" do
    results = described_class.new(website_key: "default", include_unpublished: true).results

    expect(results.map(&:id)).to include(unpublished_profile.id)
  end

  it "keeps organizations out of the member directory" do
    results = described_class.new(website_key: "default").results
    expect(results.map(&:id)).not_to include(organization_profile.id)
  end

  it "filters the organization directory by type and sector" do
    results = described_class.new(
      website_key: "default",
      profile_type: "organization",
      organization_type: "professional_network",
      sector: "technology",
    ).results

    expect(results.map(&:id)).to contain_exactly(organization_profile.id)
  end

  it "matches free-text filters like sector and skill on a partial value" do
    freelancer_profile.update!(data: freelancer_profile.data.merge("skills" => ["Logo design"]))

    sector_results = described_class.new(
      website_key: "default", profile_type: "organization", sector: "tech"
    ).results
    expect(sector_results.map(&:id)).to contain_exactly(organization_profile.id)

    skill_results = described_class.new(website_key: "default", skill: "logo").results
    expect(skill_results.map(&:id)).to contain_exactly(freelancer_profile.id)
  end

  it "finds organizations by needs through free text search" do
    results = described_class.new(
      website_key: "default", profile_type: "organization", query: "Partners"
    ).results
    expect(results.map(&:id)).to contain_exactly(organization_profile.id)
  end

  it "filters to only those offering at least one service" do
    results = described_class.new(website_key: "default", offering_services: true).results
    expect(results.map(&:id)).to contain_exactly(freelancer_profile.id)
  end

  it "finds a profile by what it offers via free text search" do
    results = described_class.new(website_key: "default", query: "Logo design").results
    expect(results.map(&:id)).to contain_exactly(freelancer_profile.id)
  end

  it "filters organizations by whether they offer mentoring" do
    results = described_class.new(
      website_key: "default", profile_type: "organization", offers_mentoring: true
    ).results
    expect(results.map(&:id)).to contain_exactly(organization_profile.id)
  end

  it "filters organizations by collaboration interest" do
    results = described_class.new(
      website_key: "default", profile_type: "organization", collaboration_interest: "Joint research"
    ).results
    expect(results.map(&:id)).to contain_exactly(organization_profile.id)
  end

  it "filters by aspiration field and mentoring or business intent" do
    aspirations = ProfessionalNetwork::Aspirations.new(freelancer_user)
    aspirations.assign(
      "field" => "Technology",
      "subfield" => "Data science",
      "mentoring_interests" => ["mentoring_opportunity"],
      "business_interests" => ["hiring_candidates"],
    )
    aspirations.save!

    results = described_class.new(
      website_key: "default",
      aspiration_field: "technology",
      aspiration_subfield: "data science",
      mentoring_interest: "mentoring_opportunity",
      business_interest: "hiring_candidates",
    ).results

    expect(results.map(&:id)).to contain_exactly(freelancer_profile.id)
  end
end
