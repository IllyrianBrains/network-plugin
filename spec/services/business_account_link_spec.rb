# frozen_string_literal: true

require "rails_helper"

RSpec.describe ProfessionalNetwork::BusinessAccountLink do
  fab!(:owner) { Fabricate(:user) }
  fab!(:business) { Fabricate(:user, username: "acme-studio") }
  let!(:business_profile) do
    ProfessionalNetwork::Profile.create!(
      user: business,
      website_key: "default",
      profile_type: "organization",
      data: {},
    )
  end

  describe ".validate!" do
    it "accepts a separate organization account on the same website" do
      expect do
        described_class.validate!(
          usernames: [business.username],
          owner: owner,
          website_key: "default",
        )
      end
        .not_to raise_error
    end

    it "accepts multiple organization accounts" do
      second_business = Fabricate(:user)
      ProfessionalNetwork::Profile.create!(
        user: second_business,
        website_key: "default",
        profile_type: "organization",
        data: {},
      )

      expect do
        described_class.validate!(
          usernames: [business.username, second_business.username],
          owner: owner,
          website_key: "default",
        )
      end.not_to raise_error
    end

    it "rejects an unknown account" do
      expect do
        described_class.validate!(
          usernames: ["missing-business"],
          owner: owner,
          website_key: "default",
        )
      end
        .to raise_error(Discourse::InvalidParameters)
    end

    it "rejects the member's own account" do
      expect do
        described_class.validate!(
          usernames: [owner.username],
          owner: owner,
          website_key: "default",
        )
      end
        .to raise_error(Discourse::InvalidParameters)
    end

    it "rejects an account without an organization profile" do
      person = Fabricate(:user)

      expect do
        described_class.validate!(
          usernames: [person.username],
          owner: owner,
          website_key: "default",
        )
      end
        .to raise_error(Discourse::InvalidParameters)
    end

    it "rejects an organization profile from another website" do
      expect do
        described_class.validate!(
          usernames: [business.username],
          owner: owner,
          website_key: "elsewhere",
        )
      end
        .to raise_error(Discourse::InvalidParameters)
    end
  end
end
