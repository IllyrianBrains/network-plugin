# frozen_string_literal: true
module ProfessionalNetwork
  class ActivityController < BaseController
    MAX_ITEMS = 20

    def index
      user = User.find_by(username_lower: params[:username].to_s.downcase)
      raise Discourse::NotFound unless user

      profile = Profile.find_by(user_id: user.id, website_key: website_key)
      allowed = profile && (profile.public_profile? || current_user&.id == user.id || guardian.is_staff?)
      raise Discourse::NotFound unless allowed

      # Discourse is authoritative for topic visibility. Never expose restricted topics
      # through the professional-network endpoint, even to signed-in viewers.
      shared = SharedPost.where(user_id: user.id, website_key: website_key).order(created_at: :desc).limit(100).includes(:topic)
      shared_ids = shared.map(&:topic_id)
      shared_items = shared.filter_map do |share|
        topic = share.topic
        next unless topic && !topic.deleted_at && guardian.can_see?(topic)
        {
          kind: "linkedin_share", topic_id: topic.id, title: topic.title,
          slug: topic.slug, source_url: share.source_url,
          # This records who shared the URL; it does not prove LinkedIn authorship.
          attribution: "shared_by_member", created_at: share.created_at.iso8601,
          replies: topic.reply_count
        }
      end

      # Native topics started by the member, not their replies to other topics.
      native_items = Topic.where(user_id: user.id, deleted_at: nil)
        .where.not(id: shared_ids)
        .order(created_at: :desc).limit(100).filter_map do |topic|
          next unless guardian.can_see?(topic)
          {
            kind: "discourse_topic", topic_id: topic.id, title: topic.title,
            slug: topic.slug, source_url: nil, attribution: "authored_locally",
            created_at: topic.created_at.iso8601, replies: topic.reply_count
          }
        end

      items = (shared_items + native_items)
        .sort_by { |item| item[:created_at] }.reverse.first(MAX_ITEMS)
      render json: { username: user.username, website_key: website_key, items: items }
    end
  end
end
