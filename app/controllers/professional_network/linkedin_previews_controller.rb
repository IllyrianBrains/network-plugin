# frozen_string_literal: true

module ProfessionalNetwork
  class LinkedinPreviewsController < BaseController
    def show
      owner!
      RateLimiter.new(current_user, "professional_network_linkedin_preview", 20, 1.minute).performed!

      preview = LinkedinPostPreview.fetch(params[:url].to_s) || {}
      render json: { text: preview[:text], tags: preview[:tags] || [] }
    rescue RateLimiter::LimitExceeded
      render json: { text: nil, tags: [] }, status: :too_many_requests
    end
  end
end
