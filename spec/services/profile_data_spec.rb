# frozen_string_literal: true

require "rails_helper"

RSpec.describe ProfessionalNetwork::ProfileData do
  describe ".normalize" do
    it "normalizes the searchable website profile fields" do
      result = described_class.normalize(
        "name" => "  Ada Example  ",
        "fields_of_expertise" => [" Technology ", "Technology"],
        "skills" => [" Ruby "],
        "website" => "https://example.com/profile"
      )

      expect(result).to include(
        "name" => "Ada Example",
        "fields_of_expertise" => ["Technology"],
        "skills" => ["Ruby"]
      )
    end

    it "rejects non-array filter fields" do
      expect { described_class.normalize("skills" => "Ruby") }
        .to raise_error(Discourse::InvalidParameters)
    end

    it "rejects unsafe profile URLs" do
      expect { described_class.normalize("website" => "javascript:alert(1)") }
        .to raise_error(Discourse::InvalidParameters)
    end

    it "accepts the open-to-work/hiring status flags and the github/twitter links" do
      result = described_class.normalize(
        "open_to_work" => true, "hiring" => false,
        "github_url" => "https://github.com/ada", "twitter_url" => "https://x.com/ada",
        "pronouns" => " she/her "
      )

      expect(result).to include(
        "open_to_work" => true, "hiring" => false,
        "github_url" => "https://github.com/ada", "twitter_url" => "https://x.com/ada",
        "pronouns" => "she/her"
      )
    end

    it "rejects a non-boolean status flag" do
      expect { described_class.normalize("open_to_work" => "yes") }
        .to raise_error(Discourse::InvalidParameters)
    end

    it "accepts the shared professional experience levels" do
      %w[student junior mid senior expert].each do |level|
        expect(described_class.normalize("experience_level" => level))
          .to include("experience_level" => level)
      end
    end

    it "rejects an unknown professional experience level" do
      expect { described_class.normalize("experience_level" => "principal") }
        .to raise_error(Discourse::InvalidParameters)
    end

    it "rejects an unsafe github/twitter link" do
      expect { described_class.normalize("github_url" => "javascript:alert(1)") }
        .to raise_error(Discourse::InvalidParameters)
    end

    it "normalizes volunteering and honors the same way as experience/education" do
      result = described_class.normalize(
        "volunteering" => [{ "organization" => " Red Cross ", "role" => "Coordinator" }],
        "honors" => [{ "title" => " Community Award ", "year" => "2020" }]
      )

      expect(result["volunteering"]).to eq([{ "organization" => "Red Cross", "role" => "Coordinator" }])
      expect(result["honors"]).to eq([{ "title" => "Community Award", "year" => "2020" }])
    end

    it "preserves structured years and current-role flags" do
      result = described_class.normalize(
        "experience" => [{ "title" => "Engineer", "start_year" => 2020, "is_current" => true }]
      )

      expect(result["experience"]).to eq(
        [{ "title" => "Engineer", "start_year" => 2020, "is_current" => true }]
      )
    end

    it "rejects a non-array volunteering/honors value" do
      expect { described_class.normalize("honors" => "Community Award") }
        .to raise_error(Discourse::InvalidParameters)
    end

    it "accepts the commercial availability fields" do
      result = described_class.normalize(
        "availability" => "part_time", "open_to_consulting" => true,
        "freelance_rate" => "$80-120/hr", "minimum_project_size" => "$2,000"
      )

      expect(result).to include(
        "availability" => "part_time", "open_to_consulting" => true,
        "freelance_rate" => "$80-120/hr", "minimum_project_size" => "$2,000"
      )
    end

    it "rejects an availability value outside the fixed list" do
      expect { described_class.normalize("availability" => "whenever") }
        .to raise_error(Discourse::InvalidParameters)
    end

    it "rejects a non-boolean open_to_consulting" do
      expect { described_class.normalize("open_to_consulting" => "sure") }
        .to raise_error(Discourse::InvalidParameters)
    end

    it "normalizes public status and contact-link fields" do
      result = described_class.normalize(
        "open_to_collaboration" => true,
        "open_to_speaking" => false,
        "open_to_volunteering" => true,
        "open_to_relocation" => false,
        "portfolio_url" => " https://portfolio.example.com ",
        "calendar_url" => "https://calendar.example.com/member",
      )

      expect(result).to include(
        "open_to_collaboration" => true,
        "open_to_speaking" => false,
        "open_to_volunteering" => true,
        "open_to_relocation" => false,
        "portfolio_url" => "https://portfolio.example.com",
        "calendar_url" => "https://calendar.example.com/member",
      )
    end

    it "normalizes a list of services offered" do
      result = described_class.normalize(
        "services" => [{ "title" => " Logo design ", "rate" => "$150 flat", "description" => " 3 concepts, 2 revisions " }]
      )

      expect(result["services"]).to eq(
        [{ "title" => "Logo design", "rate" => "$150 flat", "description" => "3 concepts, 2 revisions" }]
      )
    end

    it "limits the number of services offered" do
      expect { described_class.normalize("services" => Array.new(31) { { "title" => "Service" } }) }
        .to raise_error(Discourse::InvalidParameters)
    end

    it "rejects a non-array services value" do
      expect { described_class.normalize("services" => "Logo design") }
        .to raise_error(Discourse::InvalidParameters)
    end
  end
end
