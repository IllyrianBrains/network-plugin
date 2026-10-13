# frozen_string_literal: true

require "rails_helper"

RSpec.describe ProfessionalNetwork::BusinessAccountLink do
  fab!(:owner) { Fabricate(:user) }
  fab!(:business) { Fabricate(:user, username: "acme-studio") }

  describe ".validate!" do
    it "accepts another forum account" do
      expect { described_class.validate!(username: business.username, owner: owner) }
        .not_to raise_error
    end

    it "rejects an unknown account" do
      expect { described_class.validate!(username: "missing-business", owner: owner) }
        .to raise_error(Discourse::InvalidParameters)
    end

    it "rejects the member's own account" do
      expect { described_class.validate!(username: owner.username, owner: owner) }
        .to raise_error(Discourse::InvalidParameters)
    end
  end
end
