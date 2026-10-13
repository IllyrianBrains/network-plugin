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
      }
    end

    def public_h
      metadata.merge(
        profile: @profile.data,
        aspirations: Aspirations.new(@user).public_h,
        timezone: @user.user_option&.timezone,
      )
    end

    def linked_members
      return [] unless @profile.profile_type == "organization"

      Profile.published.people.for_website(@profile.website_key)
        .where("lower(data->>'business_username') = ?", @user.username.downcase)
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
