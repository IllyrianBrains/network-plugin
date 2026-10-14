# frozen_string_literal: true

module ProfessionalNetwork
  class AdminHealthController < BaseController
    requires_plugin ProfessionalNetwork::PLUGIN_NAME

    def show
      raise Discourse::InvalidAccess unless guardian.is_admin?

      profiles = Profile.for_website(website_key)
      cities = City.for_website(website_key)
      render json: {
        website_key: website_key,
        profiles: profile_counts(profiles),
        cities: city_counts(cities),
        pending_imports: ImportDraft.where(website_key: website_key, status: "pending").count,
        broken_business_links: broken_business_links(profiles.people),
        failed_linkedin_previews: failed_linkedin_previews,
      }
    end

    private

    def profile_counts(profiles)
      {
        total: profiles.count,
        published: profiles.published.count,
        private: profiles.where(public_profile: false).count,
        stale: profiles.where("COALESCE(reviewed_at, updated_at) < ?", 6.months.ago).count,
        verified: profiles.where.not(verified_at: nil).count,
      }
    end

    def city_counts(cities)
      { total: cities.count, active: cities.active.count, missing_coordinates: cities.where(lat: nil).count }
    end

    def broken_business_links(profiles)
      usernames = User.where(id: Profile.for_website(website_key).organizations.select(:user_id)).pluck(:username_lower)
      profiles.count do |profile|
        linked_usernames = Array(profile.data["organization_usernames"])
        linked_usernames = Array(profile.data["business_username"]) if linked_usernames.empty?
        linked_usernames.any? { |username| !usernames.include?(username.to_s.downcase) }
      end
    end

    def failed_linkedin_previews
      key = "failed_linkedin_previews:#{website_key}"
      PluginStore.get(ProfessionalNetwork::PLUGIN_NAME, key).to_i
    end
  end
end
