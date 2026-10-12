# frozen_string_literal: true

require "rails_helper"

RSpec.describe ProfessionalNetwork::Aspirations do
  fab!(:user)

  subject(:aspirations) { described_class.new(user) }

  describe "#assign and #save!" do
    it "persists field, subfield, mentoring and business interests, and the note" do
      aspirations.assign(
        "field" => " Engineering Leadership ",
        "subfield" => " Platform engineering ",
        "mentoring_interests" => ["mentor_connection", "mentor_connection"],
        "mentoring_wanted_types" => %w[project_guidance technical_skills],
        "mentoring_provided_types" => ["workshops"],
        "business_interests" => ["cofounder_intro"],
        "note" => " Looking for a technical co-founder. ",
      )
      aspirations.save!

      reloaded = described_class.new(user)
      expect(reloaded.field).to eq("Engineering Leadership")
      expect(reloaded.subfield).to eq("Platform engineering")
      expect(reloaded.mentoring_interests).to eq(["mentor_connection"])
      expect(reloaded.mentoring_wanted_types).to eq(%w[project_guidance technical_skills])
      expect(reloaded.mentoring_provided_types).to eq(["workshops"])
      expect(reloaded.business_interests).to eq(["cofounder_intro"])
      expect(reloaded.note).to eq("Looking for a technical co-founder.")
    end

    it "rejects a mentoring interest outside the fixed list" do
      expect { aspirations.assign("mentoring_interests" => ["something_else"]) }
        .to raise_error(Discourse::InvalidParameters)
    end

    it "rejects a business interest outside the fixed list" do
      expect { aspirations.assign("business_interests" => ["something_else"]) }
        .to raise_error(Discourse::InvalidParameters)
    end

    it "rejects a return plan outside the fixed list" do
      expect { aspirations.assign("return_plan" => "definitely") }
        .to raise_error(Discourse::InvalidParameters)
    end

    it "rejects a note over the length limit" do
      expect { aspirations.assign("note" => "a" * 1001) }
        .to raise_error(Discourse::InvalidParameters)
    end
  end

  describe "#public_h" do
    it "is empty when nothing has been set" do
      expect(aspirations.public_h).to eq({})
    end

    it "never includes the private return plan" do
      aspirations.assign("field" => "Engineering Leadership", "return_plan" => "yes", "return_countries" => ["albania"])
      aspirations.save!

      expect(aspirations.public_h.keys).not_to include("return_plan", "return_countries")
    end


    it "includes structured mentoring types" do
      aspirations.assign(
        "mentoring_wanted_types" => ["career_orientation"],
        "mentoring_provided_types" => ["workshops"],
      )

      expect(aspirations.public_h).to include(
        "mentoring_wanted_types" => ["career_orientation"],
        "mentoring_provided_types" => ["workshops"],
      )
    end
  end

  describe "#private_h" do
    it "carries the return plan and countries" do
      aspirations.assign("return_plan" => "maybe", "return_countries" => ["albania", "kosovo"])
      aspirations.save!

      expect(aspirations.private_h).to eq("return_plan" => "maybe", "return_countries" => %w[albania kosovo])
    end
  end

  describe "#seeking_mentoring? and #offering_mentoring?" do
    it "treats mentor_connection and career_coaching as seeking" do
      aspirations.assign("mentoring_interests" => ["career_coaching"])
      expect(aspirations.seeking_mentoring?).to eq(true)
      expect(aspirations.offering_mentoring?).to eq(false)
    end

    it "treats mentoring_opportunity as offering" do
      aspirations.assign("mentoring_interests" => ["mentoring_opportunity"])
      expect(aspirations.seeking_mentoring?).to eq(false)
      expect(aspirations.offering_mentoring?).to eq(true)
    end
  end
end
