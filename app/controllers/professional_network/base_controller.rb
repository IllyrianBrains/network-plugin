# frozen_string_literal: true
module ProfessionalNetwork
  class BaseController < ::ApplicationController
    before_action :ensure_enabled
    private
    def ensure_enabled
      raise Discourse::NotFound unless SiteSetting.professional_network_enabled
    end
    def owner!
      raise Discourse::InvalidAccess unless current_user
    end

    def website_key
      value = params[:website_key].presence || "default"
      raise Discourse::InvalidParameters.new(:website_key) unless value.match?(Profile::WEBSITE_KEY)
      value
    end
    def profile_params
      data = params.require(:data).permit!.to_h
      allowed = %w[
        name headline company location city country about fields_of_expertise skills languages
        website linkedin_url avatar profile_url portfolio_url calendar_url membership_type
        experience_level certifications
        experience education pronouns github_url twitter_url open_to_work hiring volunteering honors
        availability open_to_consulting freelance_rate minimum_project_size services
        industry current_role can_help_with looking_for ideal_connection preferred_locations
        availability_timing contact_preference meeting_preference open_to_introductions
        open_to_collaboration open_to_speaking open_to_volunteering open_to_relocation
      ]
      ProfileData.normalize(data.slice(*allowed))
    end

    def aspirations_params
      raw = params[:aspirations]
      raw ? raw.permit!.to_h : {}
    end
  end
end
