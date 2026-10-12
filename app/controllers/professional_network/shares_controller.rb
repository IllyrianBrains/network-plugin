# frozen_string_literal: true
require "uri"
require "digest"
module ProfessionalNetwork
  class SharesController < BaseController
    def index
      user = User.find_by(username_lower: params[:username].downcase)
      raise Discourse::NotFound unless user
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
      category_id = SiteSetting.professional_network_category_id
      category = Category.find_by(id: category_id)
      raise Discourse::InvalidParameters.new(:category) unless category && guardian.can_create_topic_on_category?(category)
      title = params[:title].to_s.strip
      title = "LinkedIn post shared by #{current_user.username}" if title.empty?
      commentary = params[:commentary].to_s.strip
      raw_post = "#{commentary}

Original LinkedIn post: #{normalized}".strip
      creator = PostCreator.create!(current_user, title: title, raw: raw_post,
                                    category: category.id, skip_validations: false)
      share = SharedPost.create!(user_id: current_user.id, topic_id: creator.topic.id,
                                 website_key: website_key, source_url: normalized, source_key: key)
      render json: { topic_id: share.topic_id, website_key: share.website_key, url: share.source_url }, status: :created
    rescue URI::InvalidURIError
      raise Discourse::InvalidParameters.new(:url)
    end
  end
end
