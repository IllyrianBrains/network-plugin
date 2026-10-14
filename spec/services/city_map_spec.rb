# frozen_string_literal: true

require "rails_helper"

RSpec.describe ProfessionalNetwork::CityMap do
  it "returns only active cities with complete coordinates from the requested website" do
    visible = ProfessionalNetwork::City.create!(website_key: "default", name: "Tirana", lat: 41, lng: 19)
    ProfessionalNetwork::City.create!(website_key: "default", name: "Draft", status: "paused", lat: 40, lng: 20)
    ProfessionalNetwork::City.create!(website_key: "default", name: "Missing coordinates")
    ProfessionalNetwork::City.create!(website_key: "other", name: "Rome", lat: 42, lng: 12)

    cities = described_class.new(website_key: "default").data[:cities]

    expect(cities.map { |city| city[:id] }).to eq([visible.id])
  end

  describe "filtering" do
    fab!(:tirana_user) { Fabricate(:user) }
    fab!(:rome_user) { Fabricate(:user) }
    fab!(:alumni_group) { Fabricate(:group, name: "alumni") }

    let!(:tirana_city) { ProfessionalNetwork::City.create!(website_key: "default", name: "Tirana", lat: 41, lng: 19) }
    let!(:rome_city) { ProfessionalNetwork::City.create!(website_key: "default", name: "Rome", lat: 42, lng: 12) }

    let!(:tirana_profile) do
      ProfessionalNetwork::Profile.create!(
        user: tirana_user, website_key: "default", public_profile: true,
        data: { "name" => "Tirana One", "city" => "Tirana", "fields_of_expertise" => ["Engineering"] },
      )
    end
    let!(:rome_profile) do
      ProfessionalNetwork::Profile.create!(
        user: rome_user, website_key: "default", public_profile: true,
        data: { "name" => "Rome One", "city" => "Rome", "fields_of_expertise" => ["Design"] },
      )
    end

    before { alumni_group.add(tirana_user) }

    def counts_by_id(data)
      data[:cities].index_by { |city| city[:id] }.transform_values { |city| city[:member_count] }
    end

    it "only counts members matching the field filter towards each city's member_count" do
      data = described_class.new(website_key: "default", field: "Engineering").data

      expect(counts_by_id(data)[tirana_city.id]).to eq(1)
      expect(counts_by_id(data)[rome_city.id]).to eq(0)
    end

    it "only counts members matching the group filter towards each city's member_count" do
      data = described_class.new(website_key: "default", group: "alumni").data

      expect(counts_by_id(data)[tirana_city.id]).to eq(1)
      expect(counts_by_id(data)[rome_city.id]).to eq(0)
    end

    it "exposes the distinct field and group options available across published profiles" do
      data = described_class.new(website_key: "default").data

      expect(data[:field_options]).to eq(%w[Design Engineering])
      expect(data[:group_options]).to eq(["alumni"])
    end
  end
end
