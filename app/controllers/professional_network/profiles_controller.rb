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
      user = target_user!
      aspirations_attrs = aspirations_params
      Aspirations.validate!(aspirations_attrs)

      data = profile_params
      requested_type = params[:profile_type].presence || "person"
      raise Discourse::InvalidParameters.new(:profile_type) unless Profile::PROFILE_TYPES.include?(requested_type)
      BusinessAccountLink.validate!(username: data["business_username"], owner: user) if requested_type == "person"

      profile = Profile.find_or_initialize_by(user_id: user.id, website_key: website_key)
      if profile.persisted? && profile.profile_type != requested_type
        raise Discourse::InvalidAccess
      end
      profile.profile_type = requested_type
      profile.data = data
      profile.public_profile = ActiveModel::Type::Boolean.new.cast(params[:public_profile])
      profile.save!

      aspirations = Aspirations.new(user)
      if requested_type == "person"
        aspirations.assign(aspirations_attrs)
        aspirations.save!
      end

      render json: profile_json(profile, include_private: true)
    end

    def destroy
      user = target_user!
      ProfileReset.new(user: user, website_key: website_key).call
      head :no_content
    end

    def index
      profiles = DirectorySearch.new(
        website_key: website_key,
        profile_type: params[:profile_type],
        query: params[:q],
        city: params[:city],
        country: params[:country],
        field: params[:field],
        skill: params[:skill],
        experience_level: params[:experience_level],
        membership_type: params[:membership_type],
        availability: params[:availability],
        open_to_consulting: params[:open_to_consulting],
        offering_services: params[:offering_services],
        aspiration_field: params[:aspiration_field],
        aspiration_subfield: params[:aspiration_subfield],
        mentoring_interest: params[:mentoring_interest],
        business_interest: params[:business_interest],
        organization_type: params[:organization_type],
        sector: params[:sector],
        stage: params[:stage],
        collaboration_interest: params[:collaboration_interest],
        offers_mentoring: params[:offers_mentoring],
        include_unpublished: guardian.is_staff? && params[:include_unpublished]
      ).results
      render json: { website_key: website_key, profiles: profiles.map { |profile| directory_json(profile) } }
    end

    def related
      user = User.find_by(username_lower: params[:username].downcase)
      raise Discourse::NotFound unless user
      profile = Profile.published.people.find_by!(user_id: user.id, website_key: website_key)
      matches = RelatedProfiles.new(profile, limit: params[:limit]).results
      render json: {
        website_key: website_key,
        username: user.username,
        profiles: matches.map { |match| directory_json(match[:profile]).merge(score: match[:score], reasons: match[:reasons]) }
      }
    end

    private

    def profile_json(profile, include_private:)
      presenter = ProfilePresenter.new(profile)
      aspirations = Aspirations.new(profile.user)
      data = aspirations.public_h
      data = data.merge(aspirations.private_h) if include_private
      presenter.metadata.merge(
        website_key: profile.website_key, profile: profile.data,
        public_profile: profile.public_profile, aspirations: data,
        timezone: profile.user.user_option&.timezone,
        linked_members: presenter.linked_members,
      )
    end

    def directory_json(profile)
      ProfilePresenter.new(profile).public_h.merge(public_profile: profile.public_profile)
    end
  end
end
