# frozen_string_literal: true

class AddProfileTypeToProfessionalNetworkProfiles < ActiveRecord::Migration[7.0]
  def change
    add_column :professional_network_profiles, :profile_type, :string, null: false, default: "person"
    add_index :professional_network_profiles, %i[website_key profile_type],
              name: "idx_prof_network_profiles_website_type"
  end
end
