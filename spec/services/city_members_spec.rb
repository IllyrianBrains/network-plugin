# frozen_string_literal: true

require "rails_helper"

RSpec.describe ProfessionalNetwork::CityMembers do
  fab!(:tirana_user) { Fabricate(:user) }
  fab!(:tirana_user_2) { Fabricate(:user) }
  fab!(:alumni_group) { Fabricate(:group, name: "alumni") }

  let!(:tirana_city) { ProfessionalNetwork::City.create!(website_key: "default", name: "Tirana", lat: 41, lng: 19) }
  let!(:tirana_profile) do
    ProfessionalNetwork::Profile.create!(
      user: tirana_user, website_key: "default", public_profile: true,
      data: { "name" => "Tirana One", "city" => "Tirana", "fields_of_expertise" => ["Engineering"] },
    )
  end
  let!(:tirana_profile_2) do
    ProfessionalNetwork::Profile.create!(
      user: tirana_user_2, website_key: "default", public_profile: true,
      data: { "name" => "Tirana Two", "city" => "Tirana", "fields_of_expertise" => ["Design"] },
    )
  end

  before { alumni_group.add(tirana_user) }

  it "returns every published member of the city when no filters are given" do
    usernames = described_class.new(tirana_city).profiles.map { |profile| profile.user.username }

    expect(usernames).to contain_exactly(tirana_user.username, tirana_user_2.username)
  end

  it "narrows to members matching the field filter" do
    usernames = described_class.new(tirana_city, field: "Engineering").profiles.map { |profile| profile.user.username }

    expect(usernames).to contain_exactly(tirana_user.username)
  end

  it "narrows to members matching the group filter" do
    usernames = described_class.new(tirana_city, group: "alumni").profiles.map { |profile| profile.user.username }

    expect(usernames).to contain_exactly(tirana_user.username)
  end

  it "narrows to members matching the search filter" do
    usernames = described_class.new(tirana_city, search: "Tirana Two").profiles.map { |profile| profile.user.username }

    expect(usernames).to contain_exactly(tirana_user_2.username)
  end
end
