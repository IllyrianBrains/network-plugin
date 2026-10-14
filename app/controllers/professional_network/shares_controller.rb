# frozen_string_literal: true
require "uri"
require "digest"
module ProfessionalNetwork
  class SharesController < BaseController
    requires_plugin ProfessionalNetwork::PLUGIN_NAME

    def index
      user = User.find_by(username_lower: params[:username].downcase)
      raise Discourse::NotFound unless user

      profile = Profile.find_by(user_id: user.id, website_key: website_key)
      allowed = profile && (profile.public_profile? || current_user&.id == user.id || guardian.is_staff?)
      raise Discourse::NotFound unless allowed

      shares = SharedPost.where(user_id: user.id, website_key: website_key).order(created_at: :desc).limit(50).select { |s| s.topic && guardian.can_see?(s.topic) }
      render json: { website_key: website_key, posts: shares.map { |s| { topic_id: s.topic_id, url: s.source_url, created_at: s.created_at } } }
    end

    def create
      owner!
      raw = params.require(:url).to_s.strip
      uri = URI.parse(raw)
      host = uri.host.to_s.downcase
      valid = uri.scheme == "https" && %w[linkedin.com www.linkedin.com].include?(host) &&
        (uri.path.start_with?("/posts/", "/feed/update/")) && uri.userinfo.nil?
      raise Discourse::InvalidParameters.new(:url) unless valid
      uri.fragment = nil
      uri.query = nil
      normalized = uri.to_s.sub(%r{/+$}, "")
      key = Digest::SHA256.hexdigest(normalized)
      if SharedPost.exists?(user_id: current_user.id, website_key: website_key, source_key: key)
        raise Discourse::InvalidParameters.new(:url)
      end
      category_id = params[:category_id].presence || SiteSetting.professional_network_category_id
      category = Category.find_by(id: category_id)
      raise Discourse::InvalidParameters.new(:category) unless category && guardian.can_create_topic_on_category?(category)
      title = params[:title].to_s.strip
      raise Discourse::InvalidParameters.new(:title) if title.empty?
      commentary = params[:commentary].to_s.strip
      raw_post = "#{commentary}

Original LinkedIn post: #{normalized}".strip
      tags = tags_param
      creator = PostCreator.new(current_user, title: title, raw: raw_post,
                                category: category.id, tags: tags, skip_validations: false)
      post = creator.create
      if creator.errors.present?
        render json: { errors: creator.errors.full_messages }, status: :unprocessable_entity
        return
      end
      # The post_created hook in plugin.rb also matches the "Original LinkedIn
      # post:" marker line above and may have already recorded this share;
      # find_or_create_by! keeps this idempotent instead of hitting the
      # unique (user_id, website_key, source_key) index.
      share = SharedPost.find_or_create_by!(user_id: current_user.id, website_key: website_key,
                                            source_key: key) do |s|
        s.topic_id = post.topic.id
        s.source_url = normalized
      end
      render json: { topic_id: share.topic_id, website_key: share.website_key, url: share.source_url }, status: :created
    rescue URI::InvalidURIError
      raise Discourse::InvalidParameters.new(:url)
    end

    private

    # Hashtags pulled from the LinkedIn post plus a fixed "linkedin" marker
    # tag. Discourse itself validates/creates these against the site's
    # tagging rules (SiteSetting.tagging_enabled, create-tag permissions),
    # so an unusable name here is just silently dropped, not an error.
    def tags_param
      return unless SiteSetting.tagging_enabled

      extra = Array(params[:tags]).map { |tag| tag.to_s.strip.delete_prefix("#").downcase }
      (["linkedin"] + extra).reject(&:blank?).uniq.first(10)
    end
  end
end
