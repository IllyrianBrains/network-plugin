# frozen_string_literal: true

require "rails_helper"
require "tempfile"

RSpec.describe ProfessionalNetwork::CityImporter do
  def import_csv(contents, website_key: "default")
    Tempfile.create(["cities", ".csv"]) do |file|
      file.write(contents)
      file.flush
      return described_class.new(path: file.path, website_key: website_key).import!
    end
  end

  it "creates canonical cities with coordinates and aliases" do
    result = import_csv("name,country,lat,lng,aliases,status\nRoma,Italy,41.9028,12.4964,Rome|Rom,active\n")
    city = ProfessionalNetwork::City.find_by!(website_key: "default", slug: "roma")

    expect(result).to eq(created: 1, updated: 0)
    expect(city).to have_attributes(country: "Italy", aliases: %w[Rome Rom], status: "active")
  end

  it "updates an existing website-scoped city without duplicating it" do
    ProfessionalNetwork::City.create!(website_key: "illyria", name: "Tirana", lat: 41, lng: 19)

    result = import_csv("name,country,lat,lng\nTirana,Albania,41.3275,19.8187\n", website_key: "illyria")

    expect(result).to eq(created: 0, updated: 1)
    expect(ProfessionalNetwork::City.for_website("illyria").sole.country).to eq("Albania")
  end

  it "reports the CSV line when coordinates are invalid" do
    expect { import_csv("name,lat,lng\nNowhere,120,12\n") }
      .to raise_error(ArgumentError, /CSV line 2/)
  end
end
