# frozen_string_literal: true

module ProfessionalNetwork
  class ProfileReset
    CUSTOM_FIELDS = %w[
      pn_aspiration_field pn_aspiration_subfield pn_aspirations_note
      pn_mentoring_interests pn_mentoring_wanted_types
      pn_mentoring_provided_types pn_mentoring_note pn_business_interests
      pn_return_plan pn_return_countries pn_recommendation_priorities
    ].freeze

    def initialize(user:, website_key:)
      @user = user
      @website_key = website_key
    end

    def call
      Profile.transaction do
        Profile.find_by!(user_id: user.id, website_key: website_key).destroy!
        ImportDraft.where(user_id: user.id, website_key: website_key).delete_all
        RecommendationFeedback.for_website(website_key)
          .where("user_id = :id OR recommended_user_id = :id", id: user.id).delete_all
        CUSTOM_FIELDS.each { |field| user.custom_fields.delete(field) }
        user.save_custom_fields
      end
    end

    private

    attr_reader :user, :website_key
  end
end
