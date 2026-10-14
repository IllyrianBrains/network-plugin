# frozen_string_literal: true

module ProfessionalNetwork
  class RecommendationsController < BaseController
    requires_plugin ProfessionalNetwork::PLUGIN_NAME

    def index
      owner!
      profile = Profile.people.find_by(user_id: current_user.id, website_key: website_key)
      ready = profile.present? && profile.data_present?

      render json: {
        website_key: website_key,
        profile_ready: ready,
        profiles: recommendations(ready ? profile : nil),
      }
    end

    def feedback
      owner!
      recommended = recommended_user!
      record = feedback_for(recommended)
      record.assign_attributes(feedback_params)
      record.save!
      render json: feedback_json(record)
    end

    def hidden
      owner!
      records = RecommendationFeedback.for_website(website_key)
        .where(user_id: current_user.id, hidden: true)
        .includes(recommended_user: :user_option)
        .order(updated_at: :desc)
      profiles = Profile.published.people.where(
        website_key: website_key, user_id: records.map(&:recommended_user_id),
      ).index_by(&:user_id)
      render json: {
        profiles: records.filter_map do |record|
          profile = profiles[record.recommended_user_id]
          ProfilePresenter.new(profile).public_h.merge(feedback: feedback_json(record)) if profile
        end,
      }
    end

    def introduction
      owner!
      recommended = recommended_user!
      profile = Profile.published.people.find_by!(user_id: recommended.id, website_key: website_key)
      raise Discourse::InvalidAccess unless profile.data["open_to_introductions"]
      record = feedback_for(recommended)
      if record.introduction_topic_id
        render json: feedback_json(record).merge(topic_id: record.introduction_topic_id)
        return
      end
      RateLimiter.new(current_user, "professional_network_introduction", 5, 1.day).performed!

      post = PostCreator.create!(
        current_user,
        title: "Professional introduction: #{recommended.username}",
        raw: introduction_message(recommended),
        archetype: Archetype.private_message,
        target_usernames: recommended.username,
      )
      record.update!(introduction_topic_id: post.topic_id)
      render json: feedback_json(record).merge(topic_id: post.topic_id), status: :created
    end

    private

    def recommendations(profile)
      return [] unless profile

      RelatedProfiles.new(profile, limit: params[:limit]).results.map do |match|
        feedback = RecommendationFeedback.find_by(
          website_key: website_key, user_id: current_user.id,
          recommended_user_id: match[:profile].user_id,
        )
        ProfilePresenter.new(match[:profile]).public_h.merge(
          score: match[:score],
          reasons: match[:reasons],
          feedback: feedback && feedback_json(feedback),
        )
      end
    end

    def recommended_user!
      user = User.find_by(username_lower: params[:username].downcase)
      raise Discourse::NotFound unless user
      raise Discourse::InvalidParameters.new(:username) if user.id == current_user.id
      raise Discourse::NotFound unless Profile.published.people.exists?(user_id: user.id, website_key: website_key)
      user
    end

    def feedback_for(user)
      RecommendationFeedback.find_or_initialize_by(
        website_key: website_key, user_id: current_user.id, recommended_user_id: user.id,
      )
    end

    def feedback_params
      params.require(:feedback).permit(:hidden, :helpful).to_h
    end

    def feedback_json(feedback)
      { hidden: feedback.hidden, helpful: feedback.helpful,
        introduction_topic_id: feedback.introduction_topic_id }
    end

    def introduction_message(user)
      note = params[:message].to_s.strip.first(2_000)
      body = "I'd like to connect through #{SiteSetting.professional_network_name}."
      body = "#{body}\n\n#{note}" if note.present?
      "Hi @#{user.username},\n\n#{body}"
    end
  end
end
