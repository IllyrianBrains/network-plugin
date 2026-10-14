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

    it "normalizes organization projects" do
      result = described_class.normalize(
        "organization_projects" => [
          {
            "name" => "  Community lab ",
            "description" => " Shared space ",
            "upcoming" => " Opens in June ",
          },
        ]
      )

      expect(result["organization_projects"]).to eq(
        [
          {
            "name" => "Community lab",
            "description" => "Shared space",
            "upcoming" => "Opens in June",
          },
        ]
      )
    end

    it "normalizes and validates detailed organization opportunities" do
      result = described_class.normalize(
        "organization_opportunity_details" => [
          {
            "kind" => "job",
            "title" => " Engineer ",
            "description" => " Build community tools ",
            "url" => " https://example.com/jobs/engineer ",
            "expires_on" => "2027-01-31",
          },
        ]
      )

      expect(result["organization_opportunity_details"]).to eq(
        [
          {
            "kind" => "job",
            "title" => "Engineer",
            "description" => "Build community tools",
            "url" => "https://example.com/jobs/engineer",
            "expires_on" => "2027-01-31",
          },
        ]
      )
    end

    it "accepts a mentoring opportunity kind" do
      result = described_class.normalize(
        "organization_opportunity_details" => [
          { "kind" => "mentoring", "title" => "Startup mentors wanted" },
        ]
      )

      expect(result["organization_opportunity_details"]).to eq(
        [{ "kind" => "mentoring", "title" => "Startup mentors wanted" }]
      )
    end

    it "rejects an opportunity kind outside the fixed list" do
      expect do
        described_class.normalize(
          "organization_opportunity_details" => [
            { "kind" => "internship_wrong", "title" => "Engineer" },
          ]
        )
      end.to raise_error(Discourse::InvalidParameters)
    end

    it "rejects unsafe URLs in detailed organization opportunities" do
      expect do
        described_class.normalize(
          "organization_opportunity_details" => [
            { "kind" => "job", "title" => "Engineer", "url" => "javascript:alert(1)" },
          ]
        )
      end.to raise_error(Discourse::InvalidParameters)
    end

    it "rejects invalid closing dates in detailed organization opportunities" do
      expect do
        described_class.normalize(
          "organization_opportunity_details" => [
            { "kind" => "event", "title" => "Demo day", "expires_on" => "2027-02-30" },
          ]
        )
      end.to raise_error(Discourse::InvalidParameters)
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

    it "accepts the organization type vocabulary" do
      %w[business ngo professional_network other].each do |type|
        expect(described_class.normalize("organization_type" => type))
          .to include("organization_type" => type)
      end
    end

    it "rejects an unknown organization type" do
      expect { described_class.normalize("organization_type" => "clubhouse") }
        .to raise_error(Discourse::InvalidParameters)
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

    it "accepts a separate business account username" do
      result = described_class.normalize("business_username" => "acme-studio")

      expect(result["business_username"]).to eq("acme-studio")
    end

    it "accepts multiple organization account usernames" do
      result = described_class.normalize(
        "organization_usernames" => %w[acme-studio community-group],
      )

      expect(result["organization_usernames"]).to eq(
        %w[acme-studio community-group],
      )
    end

    it "rejects an unsafe organization account username" do
      expect do
        described_class.normalize("organization_usernames" => ["../admin"])
      end.to raise_error(Discourse::InvalidParameters)
    end

    it "rejects an unsafe business account username" do
      expect { described_class.normalize("business_username" => "../admin") }
        .to raise_error(Discourse::InvalidParameters)
    end

    it "rejects a non-string business account username instead of raising" do
      expect { described_class.normalize("business_username" => ["acme-studio"]) }
        .to raise_error(Discourse::InvalidParameters)
    end

    it "rejects a non-string URL field instead of raising" do
      expect { described_class.normalize("website" => { "href" => "https://example.com" }) }
        .to raise_error(Discourse::InvalidParameters)
      expect { described_class.normalize("logo_url" => 12_345) }
        .to raise_error(Discourse::InvalidParameters)
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
