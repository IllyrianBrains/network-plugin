# frozen_string_literal: true
class CreateProfessionalNetworkTables < ActiveRecord::Migration[7.0]
  def change
    create_table :professional_network_profiles do |t|
      t.integer :user_id, null: false
      t.jsonb :data, null: false, default: {}
      t.boolean :public_profile, null: false, default: false
      t.timestamps
    end
    add_index :professional_network_profiles, :user_id, unique: true

    create_table :professional_network_import_drafts do |t|
      t.integer :user_id, null: false
      t.jsonb :data, null: false, default: {}
      t.string :status, null: false, default: "pending"
      t.timestamps
    end
    add_index :professional_network_import_drafts, :user_id

    create_table :professional_network_shared_posts do |t|
      t.integer :user_id, null: false
      t.integer :topic_id, null: false
      t.string :source_url, null: false
      t.string :source_key, null: false
      t.timestamps
    end
    add_index :professional_network_shared_posts, [:user_id, :source_key], unique: true, name: "idx_prof_network_unique_share"
    add_index :professional_network_shared_posts, :topic_id, unique: true
  end
end
