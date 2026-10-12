# frozen_string_literal: true
require "rails_helper"
RSpec.describe ProfessionalNetwork::PdfParser do
  it "parses main headings from a LinkedIn PDF text sample" do
    sample = <<~TEXT
      Contact
                                           Sample Person
      www.linkedin.com/in/sample-person     Project Manager | Sustainability
                                           Frankfurt, Hesse, Germany
      Top Skills                             Experience
      Project Finance
      Renewable Energy
      Certifications
      Expert Certificate
                                           Example Organization
                                           Project Manager
                                           October 2023 - Present (3 years)
      Page 1 of 2
      Education
      University of Tirana
      Master of Science (MSc), Finance (2007 - 2009)
    TEXT
    parsed = described_class.parse(sample)
    expect(parsed["name"]).to include("Sample Person")
    expect(parsed["skills"]).to include("Project Finance")
    expect(parsed["experience"].first).to include(
      "title" => "Project Manager",
      "organization" => "Example Organization",
      "start_year" => 2023,
      "end_year" => nil,
      "is_current" => true,
    )
    expect(parsed["education"].first).to include(
      "school" => "University of Tirana",
      "start_year" => 2007,
      "end_year" => 2009,
    )
  end
end
