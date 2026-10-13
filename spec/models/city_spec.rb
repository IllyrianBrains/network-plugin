# frozen_string_literal: true

require "rails_helper"

RSpec.describe ProfessionalNetwork::City do
  describe ".normalize_name" do
    it "lowercases and strips the name so exonyms can be matched consistently" do
      expect(described_class.normalize_name("  Rome ")).to eq("rome")
    end

    it "treats blank input as an empty string" do
      expect(described_class.normalize_name(nil)).to eq("")
    end
  end

  it "requires latitude and longitude together" do
    city = described_class.new(website_key: "default", name: "Tirana", lat: 41)

    expect(city).not_to be_valid
    expect(city.errors[:base]).to include("latitude and longitude must be provided together")
  end

  it "rejects coordinates outside valid geographic ranges" do
    city = described_class.new(website_key: "default", name: "Tirana", lat: 91, lng: 181)

    expect(city).not_to be_valid
    expect(city.errors[:lat]).to be_present
    expect(city.errors[:lng]).to be_present
  end
end
