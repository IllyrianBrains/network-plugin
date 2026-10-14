# frozen_string_literal: true

require "rails_helper"

RSpec.describe ProfessionalNetwork::ProfileExport do
  fab!(:user)

  it "exports the owner's public and private professional data" do
    profile = ProfessionalNetwork::Profile.create!(
      user: user, website_key: "default", public_profile: true,
      data: { "name" => "Ada", "skills" => ["Ruby"] },
    )
    aspirations = ProfessionalNetwork::Aspirations.new(user)
    aspirations.assign("return_plan" => "maybe", "return_countries" => ["albania"])
    aspirations.save!

    export = described_class.new(profile).data

    expect(export[:profile]).to include("name" => "Ada")
    expect(export[:aspirations]).to include("return_plan" => "maybe", "return_countries" => ["albania"])
  end
end
