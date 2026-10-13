# frozen_string_literal: true

module ProfessionalNetwork
  class RecommendationsController < BaseController
    def index
      owner!
      profile = Profile.people.find_by(user_id: current_user.id, website_key: website_key)

      render json: {
        website_key: website_key,
        profile_ready: profile.present?,
        profiles: recommendations(profile),
      }
    end

    private

    def recommendations(profile)
      return [] unless profile

      RelatedProfiles.new(profile, limit: params[:limit]).results.map do |match|
        ProfilePresenter.new(match[:profile]).public_h.merge(
          score: match[:score],
          reasons: match[:reasons],
        )
      end
    end
  end
end
