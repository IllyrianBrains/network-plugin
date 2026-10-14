# frozen_string_literal: true

module ProfessionalNetwork
  class ProfileExport
    def initialize(profile)
      @profile = profile
    end

    def data
      aspirations = Aspirations.new(@profile.user)
      {
        exported_at: Time.current,
        website_key: @profile.website_key,
        username: @profile.user.username,
        profile_type: @profile.profile_type,
        public_profile: @profile.public_profile,
        reviewed_at: @profile.reviewed_at,
        verified_at: @profile.verified_at,
        profile: @profile.data,
        aspirations: aspirations.public_h.merge(aspirations.private_h),
      }
    end
  end
end
