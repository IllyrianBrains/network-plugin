# frozen_string_literal: true

require "rails_helper"

RSpec.describe ProfessionalNetwork::CityMap do
  it "returns only active cities with complete coordinates from the requested website" do
    visible = ProfessionalNetwork::City.create!(website_key: "default", name: "Tirana", lat: 41, lng: 19)
    ProfessionalNetwork::City.create!(website_key: "default", name: "Draft", status: "paused", lat: 40, lng: 20)
    ProfessionalNetwork::City.create!(website_key: "default", name: "Missing coordinates")
    ProfessionalNetwork::City.create!(website_key: "other", name: "Rome", lat: 42, lng: 12)

    cities = described_class.new(website_key: "default").data

    expect(cities.map { |city| city[:id] }).to eq([visible.id])
  end
end
