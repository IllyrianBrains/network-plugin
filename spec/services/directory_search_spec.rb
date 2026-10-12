# frozen_string_literal: true

require "rails_helper"

RSpec.describe ProfessionalNetwork::DirectorySearch do
  fab!(:freelancer_user) { Fabricate(:user) }
  fab!(:employee_user) { Fabricate(:user) }

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

  it "filters to only those offering at least one service" do
    results = described_class.new(website_key: "default", offering_services: true).results
    expect(results.map(&:id)).to contain_exactly(freelancer_profile.id)
  end

  it "finds a profile by what it offers via free text search" do
    results = described_class.new(website_key: "default", query: "Logo design").results
    expect(results.map(&:id)).to contain_exactly(freelancer_profile.id)
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
