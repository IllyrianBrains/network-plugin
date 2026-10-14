# frozen_string_literal: true

require "rails_helper"

RSpec.describe ProfessionalNetwork::NetworkGraph do
  fab!(:tirana_user) { Fabricate(:user) }
  fab!(:tirana_user_2) { Fabricate(:user) }
  fab!(:other_city_user) { Fabricate(:user) }
  fab!(:private_user) { Fabricate(:user) }
  fab!(:other_website_user) { Fabricate(:user) }
  fab!(:acme_org_user) { Fabricate(:user) }
  fab!(:hidden_org_user) { Fabricate(:user) }
  fab!(:alumni_group) { Fabricate(:group, name: "alumni") }
  fab!(:staff_like_group) { Fabricate(:group, name: "reviewers", visibility_level: Group.visibility_levels[:staff]) }
  fab!(:automatic_group) { Fabricate(:group, name: "auto-group", automatic: true) }

  let!(:tirana_profile) do
    ProfessionalNetwork::Profile.create!(
      user: tirana_user, website_key: "default", public_profile: true,
      data: { "name" => "Tirana One", "city" => "Tirana", "fields_of_expertise" => ["Engineering"],
              "organization_usernames" => [acme_org_user.username] },
    )
  end
  let!(:tirana_profile_2) do
    ProfessionalNetwork::Profile.create!(
      user: tirana_user_2, website_key: "default", public_profile: true,
      data: { "name" => "Tirana Two", "city" => "Tirana", "fields_of_expertise" => ["Engineering", "Design"],
              "business_username" => hidden_org_user.username },
    )
  end
  let!(:other_city_profile) do
    ProfessionalNetwork::Profile.create!(
      user: other_city_user, website_key: "default", public_profile: true,
      data: { "name" => "Rome Member", "city" => "Rome" },
    )
  end
  let!(:private_profile) do
    ProfessionalNetwork::Profile.create!(
      user: private_user, website_key: "default", public_profile: false,
      data: { "name" => "Hidden Member", "city" => "Tirana" },
    )
  end
  let!(:other_website_profile) do
    ProfessionalNetwork::Profile.create!(
      user: other_website_user, website_key: "other", public_profile: true,
      data: { "name" => "Other Site Member", "city" => "Tirana" },
    )
  end
  let!(:acme_org_profile) do
    ProfessionalNetwork::Profile.create!(
      user: acme_org_user, website_key: "default", public_profile: true, profile_type: "organization",
      data: { "name" => "Acme Co", "city" => "Tirana", "sector" => "Engineering" },
    )
  end
  # Unpublished, so a member's business_username pointing at it must not fabricate a node.
  let!(:hidden_org_profile) do
    ProfessionalNetwork::Profile.create!(
      user: hidden_org_user, website_key: "default", public_profile: false, profile_type: "organization",
      data: { "name" => "Hidden Org", "city" => "Tirana" },
    )
  end

  def graph
    described_class.new(website_key: "default").data
  end

  before do
    alumni_group.add(tirana_user)
    staff_like_group.add(tirana_user)
    automatic_group.add(tirana_user)
  end

  it "links a member to the public, non-automatic groups they belong to" do
    expect(graph[:edges]).to include(
      { source: "member:#{tirana_user.username}", target: "group:alumni" },
    )
    expect(graph[:nodes]).to include(
      a_hash_including(id: "group:alumni", type: "group", label: "alumni"),
    )
  end

  it "excludes non-public and automatic groups from the graph" do
    labels = graph[:nodes].select { |node| node[:type] == "group" }.map { |node| node[:label] }

    expect(labels).not_to include("reviewers", "auto-group")
  end

  it "excludes unpublished profiles and profiles from other websites" do
    labels = graph[:nodes].map { |node| node[:label] }

    expect(labels).to include("Tirana One", "Tirana Two", "Rome Member")
    expect(labels).not_to include("Hidden Member", "Other Site Member")
  end

  it "includes the username on member nodes so the frontend can link to a profile" do
    member_node = graph[:nodes].find { |node| node[:id] == "member:#{tirana_user.username}" }

    expect(member_node[:username]).to eq(tirana_user.username)
  end

  it "counts how many members share a city or field, deduplicating the node" do
    tirana_node = graph[:nodes].find { |node| node[:id] == "city:tirana" }
    engineering_node = graph[:nodes].find { |node| node[:id] == "field:engineering" }
    design_node = graph[:nodes].find { |node| node[:id] == "field:design" }

    expect(graph[:nodes].count { |node| node[:id] == "city:tirana" }).to eq(1)
    expect(tirana_node[:count]).to eq(3) # 2 members + Acme Co
    expect(engineering_node[:count]).to eq(3) # 2 members + Acme Co's sector
    expect(design_node[:count]).to eq(1)
  end

  it "includes published organizations as their own node, sharing city/field hubs with members" do
    org_node = graph[:nodes].find { |node| node[:id] == "organization:#{acme_org_user.username}" }

    expect(org_node).to include(type: "organization", label: "Acme Co", username: acme_org_user.username)
    expect(graph[:edges]).to include({ source: "organization:#{acme_org_user.username}", target: "city:tirana" })
    expect(graph[:edges]).to include({ source: "organization:#{acme_org_user.username}", target: "field:engineering" })
  end

  it "links a member to every named organization" do
    expect(graph[:edges]).to include(
      { source: "member:#{tirana_user.username}", target: "organization:#{acme_org_user.username}" },
    )
  end

  it "does not fabricate an organization node or edge for an unpublished business_username" do
    labels = graph[:nodes].map { |node| node[:label] }

    expect(labels).not_to include("Hidden Org")
    expect(graph[:edges]).not_to include(
      { source: "member:#{tirana_user_2.username}", target: "organization:#{hidden_org_user.username}" },
    )
  end
end
