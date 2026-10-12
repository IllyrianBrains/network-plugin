# frozen_string_literal: true

class ScopeProfessionalNetworkProfilesByWebsite < ActiveRecord::Migration[7.0]
  def change
    add_column :professional_network_profiles, :website_key, :string, null: false, default: "default"
    remove_index :professional_network_profiles, :user_id
    add_index :professional_network_profiles, %i[user_id website_key], unique: true,
              name: "idx_prof_network_profile_user_website"
    add_index :professional_network_profiles, :website_key

    add_column :professional_network_import_drafts, :website_key, :string, null: false, default: "default"
    add_index :professional_network_import_drafts, %i[user_id website_key],
              name: "idx_prof_network_import_drafts_user_website"

    add_column :professional_network_shared_posts, :website_key, :string, null: false, default: "default"
    remove_index :professional_network_shared_posts, name: "idx_prof_network_unique_share"
    add_index :professional_network_shared_posts, %i[user_id website_key source_key], unique: true,
              name: "idx_prof_network_unique_share"
    add_index :professional_network_shared_posts, :website_key
  end
end
