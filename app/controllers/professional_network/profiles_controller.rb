# frozen_string_literal: true
module ProfessionalNetwork
  class ProfilesController < BaseController
    def show
      user = User.find_by(username_lower: params[:username].downcase)
      raise Discourse::NotFound unless user
      profile = Profile.find_by(user_id: user.id, website_key: website_key)
      raise Discourse::NotFound unless profile && (profile.public_profile? || current_user&.id == user.id || guardian.is_staff?)
      render json: profile_json(profile, include_private: current_user&.id == user.id || guardian.is_staff?)
    end

    def update
      owner!
      aspirations_attrs = aspirations_params
      Aspirations.validate!(aspirations_attrs)

      profile = Profile.find_or_initialize_by(user_id: current_user.id, website_key: website_key)
      profile.data = profile_params
      profile.public_profile = ActiveModel::Type::Boolean.new.cast(params[:public_profile])
      profile.save!

      aspirations = Aspirations.new(current_user)
      aspirations.assign(aspirations_attrs)
      aspirations.save!

      render json: profile_json(profile, include_private: true)
    end

    def index
      profiles = DirectorySearch.new(
        website_key: website_key,
        query: params[:q],
        city: params[:city],
        country: params[:country],
        field: params[:field],
        skill: params[:skill],
        experience_level: params[:experience_level],
        availability: params[:availability],
        open_to_consulting: params[:open_to_consulting],
        offering_services: params[:offering_services],
        aspiration_field: params[:aspiration_field],
        aspiration_subfield: params[:aspiration_subfield],
        mentoring_interest: params[:mentoring_interest],
        business_interest: params[:business_interest]
      ).results
      render json: { website_key: website_key, profiles: profiles.map { |profile| directory_json(profile) } }
    end

    def related
      user = User.find_by(username_lower: params[:username].downcase)
      raise Discourse::NotFound unless user
      profile = Profile.published.find_by!(user_id: user.id, website_key: website_key)
      matches = RelatedProfiles.new(profile, limit: params[:limit]).results
      render json: {
        website_key: website_key,
        username: user.username,
        profiles: matches.map { |match| directory_json(match[:profile]).merge(score: match[:score], reasons: match[:reasons]) }
      }
    end

    private

    def profile_json(profile, include_private:)
      aspirations = Aspirations.new(profile.user)
      data = aspirations.public_h
      data = data.merge(aspirations.private_h) if include_private
      { username: profile.user.username, website_key: profile.website_key, profile: profile.data,
        public_profile: profile.public_profile, aspirations: data, timezone: profile.user.user_option&.timezone }
    end

    def directory_json(profile)
      { username: profile.user.username, profile: profile.data, aspirations: Aspirations.new(profile.user).public_h,
        timezone: profile.user.user_option&.timezone }
    end
  end
end
