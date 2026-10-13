# frozen_string_literal: true

require "rails_helper"

RSpec.describe ProfessionalNetwork::ProfileReset do
  fab!(:user)

  it "deletes the website profile, drafts, and professional custom fields" do
    profile = ProfessionalNetwork::Profile.create!(
      user: user,
      website_key: "default",
      profile_type: "person",
      data: { "name" => "Ada" }
    )
    draft = ProfessionalNetwork::ImportDraft.create!(
      user: user,
      website_key: "default",
      data: { "name" => "Draft" }
    )
    user.custom_fields["pn_aspiration_field"] = "Engineering"
    user.custom_fields["pn_return_plan"] = "maybe"
    user.save_custom_fields

    described_class.new(user: user, website_key: "default").call

    expect { profile.reload }.to raise_error(ActiveRecord::RecordNotFound)
    expect { draft.reload }.to raise_error(ActiveRecord::RecordNotFound)
    expect(user.reload.custom_fields).not_to include(
      "pn_aspiration_field",
      "pn_return_plan"
    )
  end
end
