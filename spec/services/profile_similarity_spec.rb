# frozen_string_literal: true

require "rails_helper"

RSpec.describe ProfessionalNetwork::ProfileSimilarity do
  fab!(:source_user, :user)
  fab!(:candidate_user, :user)

  let(:source) do
    ProfessionalNetwork::Profile.new(
      user: source_user,
      data: { "headline" => "Robotics engineer", "skills" => ["automation"] },
    )
  end
  let(:candidate) do
    ProfessionalNetwork::Profile.new(
      user: candidate_user,
      data: { "headline" => "Robotics researcher", "skills" => ["automation"] },
    )
  end

  it "returns normalized cosine similarity for public profile terms" do
    score = described_class.new(source, candidate).score

    expect(score).to be_between(0, 1)
    expect(score).to be > 0
  end

  it "returns zero when profiles share no terms" do
    candidate.data = { "headline" => "Corporate lawyer" }

    expect(described_class.new(source, candidate).score).to eq(0.0)
  end
end
