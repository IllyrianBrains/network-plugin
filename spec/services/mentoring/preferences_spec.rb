# frozen_string_literal: true

require "rails_helper"

RSpec.describe ProfessionalNetwork::Mentoring::Preferences do
  fab!(:user)

  subject(:preferences) { described_class.new(user) }

  describe "#assign" do
    it "persists valid interests through the owning user" do
      preferences.assign("mentoring_interests" => %w[mentor_connection mentor_connection])
      user.save_custom_fields

      expect(described_class.new(user).interests).to eq(["mentor_connection"])
    end

    it "rejects interests outside the mentoring vocabulary" do
      expect { preferences.assign("mentoring_interests" => ["something_else"]) }
        .to raise_error(Discourse::InvalidParameters)
    end

    it "persists wanted and provided mentoring types" do
      preferences.assign(
        "mentoring_wanted_types" => %w[project_guidance technical_skills],
        "mentoring_provided_types" => %w[career_orientation workshops workshops],
      )
      user.save_custom_fields

      reloaded = described_class.new(user)
      expect(reloaded.wanted_types).to eq(%w[project_guidance technical_skills])
      expect(reloaded.provided_types).to eq(%w[career_orientation workshops])
    end
    it "rejects mentoring types outside the fixed list" do
      expect { preferences.assign("mentoring_wanted_types" => ["anything"]) }
        .to raise_error(Discourse::InvalidParameters)
    end

    it "persists a free-text mentoring note" do
      preferences.assign("mentoring_note" => "  Happy to do monthly check-ins over video.  ")
      user.save_custom_fields

      expect(described_class.new(user).note).to eq("Happy to do monthly check-ins over video.")
    end

    it "rejects a mentoring note over the character limit" do
      expect { preferences.assign("mentoring_note" => "a" * (described_class::NOTE_LIMIT + 1)) }
        .to raise_error(Discourse::InvalidParameters)
    end
  end

  describe "#seeking? and #offering?" do
    it "keeps seeking and offering intent separate" do
      preferences.assign("mentoring_interests" => ["career_coaching"])
      expect(preferences.seeking?).to eq(true)
      expect(preferences.offering?).to eq(false)
    end
  end
end
