# frozen_string_literal: true

module ProfessionalNetwork
  class ProfilePresenter
    AVATAR_SIZE = 240

    def initialize(profile)
      @profile = profile
      @user = profile.user
    end

    def metadata
      {
        username: @user.username,
        profile_type: @profile.profile_type,
        member_since: @user.created_at&.year,
        avatar_url: avatar_url(@user),
        profile_updated_at: @profile.updated_at,
        reviewed_at: @profile.reviewed_at,
        verified_at: @profile.verified_at,
        stale: @profile.stale?,
      }
    end

    def public_h
      metadata.merge(
        profile: public_profile_data,
        aspirations: Aspirations.new(@user).public_h,
        timezone: @user.user_option&.timezone,
      )
    end

    def public_profile_data
      data = @profile.data.deep_dup
      data["organization_opportunity_details"] = Array(data["organization_opportunity_details"]).reject do |item|
        item["expires_on"].present? && Date.iso8601(item["expires_on"]) < Date.current
      rescue Date::Error
        false
      end
      data
    end

    def linked_members
      return [] unless @profile.profile_type == "organization"

      Profile.published.people.for_website(@profile.website_key)
        .where(
          <<~SQL,
            lower(data->>'business_username') = :username
            OR EXISTS (
              SELECT 1
              FROM jsonb_array_elements_text(COALESCE(data->'organization_usernames', '[]'::jsonb)) linked(username)
              WHERE lower(linked.username) = :username
            )
          SQL
          username: @user.username.downcase,
        )
        .includes(:user).map do |member_profile|
          {
            username: member_profile.user.username,
            name: member_profile.data["name"],
            headline: member_profile.data["headline"],
            avatar_url: avatar_url(member_profile.user),
          }
        end
    end

    private

    def avatar_url(user)
      template = user.avatar_template.to_s.gsub("{size}", AVATAR_SIZE.to_s)
      template.present? ? UrlHelper.absolute(template) : nil
    end
  end
end
