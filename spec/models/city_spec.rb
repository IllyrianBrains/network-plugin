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
end
