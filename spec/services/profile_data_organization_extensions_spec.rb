# frozen_string_literal: true

require "rails_helper"

RSpec.describe ProfessionalNetwork::ProfileData do
  it "normalizes organization contacts and project lifecycle fields" do
    result = described_class.normalize(
      "organization_contacts" => [
        { "name" => " Ada ", "role" => " Director ", "url" => " https://example.com/ada " },
      ],
      "organization_projects" => [
        { "name" => "Lab", "status" => "active", "starts_on" => "2026-10-01", "ends_on" => "2027-01-31" },
      ],
    )

    expect(result["organization_contacts"]).to eq(
      [{ "name" => "Ada", "role" => "Director", "url" => "https://example.com/ada" }],
    )
    expect(result["organization_projects"].first).to include("status" => "active")
  end

  it "rejects unsafe contact links" do
    expect do
      described_class.normalize(
        "organization_contacts" => [{ "name" => "Ada", "url" => "javascript:alert(1)" }],
      )
    end.to raise_error(Discourse::InvalidParameters)
  end

  it "rejects unknown project statuses and invalid dates" do
    expect do
      described_class.normalize(
        "organization_projects" => [{ "name" => "Lab", "status" => "lost", "starts_on" => "tomorrow" }],
      )
    end.to raise_error(Discourse::InvalidParameters)
  end
end
