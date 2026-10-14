# frozen_string_literal: true

class AddNetworkFeedbackAndProfileReview < ActiveRecord::Migration[7.0]
  def change
    add_column :professional_network_profiles, :reviewed_at, :datetime
    add_column :professional_network_profiles, :verified_at, :datetime
    add_column :professional_network_profiles, :verified_by_id, :integer
    add_column :professional_network_profiles, :logo_upload_id, :integer

    create_table :professional_network_recommendation_feedbacks do |t|
      t.string :website_key, null: false, default: "default"
      t.integer :user_id, null: false
      t.integer :recommended_user_id, null: false
      t.boolean :hidden, null: false, default: false
      t.boolean :helpful
      t.integer :introduction_topic_id
      t.timestamps
    end

    add_index :professional_network_recommendation_feedbacks,
              %i[website_key user_id recommended_user_id], unique: true,
              name: "idx_prof_network_recommendation_feedback"
    add_index :professional_network_recommendation_feedbacks, :recommended_user_id,
              name: "idx_prof_network_feedback_recommended_user"
  end
end
