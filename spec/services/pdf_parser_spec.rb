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

  it "does not let a wrapped education title split into bogus entries" do
    sample = <<~TEXT
      Sample Person
      Page 1 of 1
      Education
      Lehman College of the City
      University of New York
      Bachelor of Arts (BA), Economics (2011 - 2015)
    TEXT
    parsed = described_class.parse(sample)
    expect(parsed["education"]).to contain_exactly(
      hash_including(
        "school" => "Lehman College of the City University of New York",
        "degree" => "Bachelor of Arts (BA), Economics",
        "start_year" => 2011,
        "end_year" => 2015,
      ),
    )
  end

  it "parses a main-body Licenses & Certifications section without wrapped titles splitting into bogus entries" do
    sample = <<~TEXT
      Sample Person
      Page 1 of 1
      Licenses & Certifications
      AWS Certified Solutions
      Architect - Associate
      Amazon Web Services
      Issued March 2022
      Credential ID ABC123
      PMP
      Project Management Institute
      Issued June 2019
    TEXT
    parsed = described_class.parse(sample)
    expect(parsed["certifications"]).to contain_exactly(
      "AWS Certified Solutions Architect - Associate · Amazon Web Services",
      "PMP · Project Management Institute",
    )
  end

  it "stops an unparsed heading like Honors & Awards from leaking into Education" do
    sample = <<~TEXT
      Sample Person
      Page 1 of 1
      Education
      University of Tirana
      Master of Science (MSc), Finance (2007 - 2009)
      Honors & Awards
      Dean's List
      Fall 2021
    TEXT
    parsed = described_class.parse(sample)
    expect(parsed["education"]).to contain_exactly(
      hash_including("school" => "University of Tirana"),
    )
  end
end
