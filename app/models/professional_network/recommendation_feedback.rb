# frozen_string_literal: true

module ProfessionalNetwork
  class RecommendationFeedback < ActiveRecord::Base
    self.table_name = "professional_network_recommendation_feedbacks"

    belongs_to :user
    belongs_to :recommended_user, class_name: "User"
    belongs_to :introduction_topic, class_name: "Topic", optional: true

    validates :website_key, presence: true, format: { with: Profile::WEBSITE_KEY }
    validates :recommended_user_id, uniqueness: { scope: %i[website_key user_id] }
    validate :different_users

    scope :for_website, ->(website_key) { where(website_key: website_key) }

    private

    def different_users
      errors.add(:recommended_user_id, "cannot be the requesting member") if user_id == recommended_user_id
    end
  end
end
