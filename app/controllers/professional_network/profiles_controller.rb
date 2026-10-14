# frozen_string_literal: true
require "csv"

module ProfessionalNetwork
  class ProfilesController < BaseController
    requires_plugin ProfessionalNetwork::PLUGIN_NAME
    # #index is the only anonymous-reachable action, and only for the public
    # organizations directory -- it enforces login itself for any other
    # profile_type (see #index below).
    requires_login except: [:index]

    def show
      user = User.find_by(username_lower: params[:username].downcase)
      raise Discourse::NotFound unless user
      profile = Profile.find_by(user_id: user.id, website_key: website_key)
      can_view = profile && (profile.public_profile? || current_user&.id == user.id || guardian.is_staff?)
      raise Discourse::NotFound unless can_view
      can_see_private = current_user&.id == user.id || guardian.is_staff?
      include_private = can_see_private && params[:preview] != "public"
      render json: profile_json(profile, include_private: include_private).merge(
        privacy_preview: can_see_private && !include_private,
      )
    end

    def update
      user = target_user!
      aspirations_attrs = aspirations_params
      Aspirations.validate!(aspirations_attrs)

      data = profile_params
      requested_type = params[:profile_type].presence || "person"
      raise Discourse::InvalidParameters.new(:profile_type) if Profile::PROFILE_TYPES.exclude?(requested_type)
      if requested_type == "person"
        organization_usernames =
          data["organization_usernames"].presence ||
            Array(data["business_username"])
        BusinessAccountLink.validate!(
          usernames: organization_usernames,
          owner: user,
          website_key: website_key,
        )
      end

      profile = Profile.find_or_initialize_by(user_id: user.id, website_key: website_key)
      if profile.persisted? && profile.profile_type != requested_type
        raise Discourse::InvalidAccess
      end
      profile.profile_type = requested_type
      profile.data = data
      profile.public_profile = ActiveModel::Type::Boolean.new.cast(params[:public_profile])
      profile.reviewed_at = Time.current
      profile.save!

      aspirations = Aspirations.new(user)
      if requested_type == "person"
        aspirations.assign(aspirations_attrs)
        aspirations.save!
      end

      render json: profile_json(profile, include_private: true)
    end

    def review
      owner!
      profile = Profile.find_by!(user_id: current_user.id, website_key: website_key)
      profile.update!(reviewed_at: Time.current)
      render json: { reviewed_at: profile.reviewed_at, stale: false }
    end

    def verify
      raise Discourse::InvalidAccess unless guardian.is_staff?
      user = User.find_by(username_lower: params[:username].downcase)
      raise Discourse::NotFound unless user

      profile = Profile.find_by!(user_id: user.id, website_key: website_key)
      raise Discourse::InvalidParameters.new(:profile_type) unless profile.profile_type == "organization"
      profile.update!(verified_at: Time.current, verified_by_id: current_user.id)
      render json: { verified_at: profile.verified_at }
    end

    def export
      owner!
      profile = Profile.find_by!(user_id: current_user.id, website_key: website_key)
      send_data JSON.pretty_generate(ProfileExport.new(profile).data),
                filename: "professional-network-profile.json", type: "application/json"
    end

    def directory_export
      raise Discourse::InvalidAccess unless guardian.is_admin?
      profiles = DirectorySearch.new(
        website_key: website_key, profile_type: params[:profile_type], per_page: 100,
      ).results
      csv = CSV.generate(headers: true) do |rows|
        rows << %w[username name headline company city country profile_type updated_at]
        profiles.each do |profile|
          rows << [profile.user.username, profile.data["name"], profile.data["headline"],
                   profile.data["company"], profile.data["city"], profile.data["country"],
                   profile.profile_type, profile.updated_at.iso8601]
        end
      end
      send_data csv, filename: "professional-network-directory.csv", type: "text/csv"
    end

    def destroy
      user = target_user!
      ProfileReset.new(user: user, website_key: website_key).call
      head :no_content
    end

    def index
      ensure_logged_in unless params[:profile_type] == "organization"
      search = DirectorySearch.new(
        website_key: website_key,
        profile_type: params[:profile_type],
        query: params[:q],
        city: params[:city],
        country: params[:country],
        field: params[:field],
        skill: params[:skill],
        industry: params[:industry],
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
        include_unpublished: guardian.is_staff? && params[:include_unpublished],
        page: params[:page],
      )
      profiles = search.results
      render json: {
        website_key: website_key,
        profiles: profiles.map { |profile| directory_json(profile) },
        pagination: { page: search.page, per_page: search.per_page, total_count: search.total_count },
      }
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
      profile_data = presenter.public_profile_data
      presenter.metadata.merge(
        website_key: profile.website_key, profile: profile_data,
        public_profile: profile.public_profile, aspirations: data,
        reviewed_at: profile.reviewed_at, verified_at: profile.verified_at,
        stale: profile.stale?,
        timezone: profile.user.user_option&.timezone,
        linked_members: presenter.linked_members,
      )
    end

    def directory_json(profile)
      ProfilePresenter.new(profile).public_h.merge(public_profile: profile.public_profile)
    end
  end
end
