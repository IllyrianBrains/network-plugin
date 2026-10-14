# frozen_string_literal: true

module ProfessionalNetwork
  class LinkedinPreviewsController < BaseController
    requires_plugin ProfessionalNetwork::PLUGIN_NAME

    def show
      owner!
      RateLimiter.new(current_user, "professional_network_linkedin_preview", 20, 1.minute).performed!

      preview = LinkedinPostPreview.fetch(params[:url].to_s) || {}
      record_failed_preview if preview[:text].blank?
      render json: { text: preview[:text], tags: preview[:tags] || [] }
    rescue RateLimiter::LimitExceeded
      render json: { text: nil, tags: [] }, status: :too_many_requests
    end

    private

    def record_failed_preview
      key = "failed_linkedin_previews:#{website_key}"
      count = PluginStore.get(ProfessionalNetwork::PLUGIN_NAME, key).to_i
      PluginStore.set(ProfessionalNetwork::PLUGIN_NAME, key, count + 1)
    end
  end
end
