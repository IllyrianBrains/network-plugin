# frozen_string_literal: true

require "rails_helper"

RSpec.describe ProfessionalNetwork::ProfilePresenter do
  fab!(:organization_user) { Fabricate(:user, username: "acme") }
  fab!(:member_user) { Fabricate(:user, username: "ada") }

  let!(:organization_profile) do
    ProfessionalNetwork::Profile.create!(
      user: organization_user,
      website_key: "example.com",
      profile_type: "organization",
      public_profile: true,
      data: { "name" => "Acme" },
    )
  end

  it "provides stable page metadata from the Discourse account" do
    metadata = described_class.new(organization_profile).metadata

    expect(metadata).to include(
      username: "acme",
      profile_type: "organization",
      member_since: organization_user.created_at.year,
    )
    expect(metadata[:avatar_url]).to be_present
    expect(metadata[:avatar_url]).not_to include("{size}")
  end

  it "exposes only public members linked to an organization on the same website" do
    ProfessionalNetwork::Profile.create!(
      user: member_user,
      website_key: "example.com",
      public_profile: true,
      data: {
        "name" => "Ada",
        "headline" => "Engineer",
        "organization_usernames" => %w[another-org ACME],
      },
    )

    expect(described_class.new(organization_profile).linked_members).to contain_exactly(
      include(username: "ada", name: "Ada", headline: "Engineer")
    )
  end

  it "archives expired opportunities from public profile data" do
    organization_profile.update!(
      data: {
        "organization_opportunity_details" => [
          { "kind" => "job", "title" => "Old role", "expires_on" => 1.day.ago.to_date.iso8601 },
          { "kind" => "job", "title" => "Current role", "expires_on" => 1.day.from_now.to_date.iso8601 },
        ],
      },
    )

    opportunities = described_class.new(organization_profile).public_profile_data[
      "organization_opportunity_details"
    ]
    expect(opportunities.map { |item| item["title"] }).to contain_exactly("Current role")
  end
end
