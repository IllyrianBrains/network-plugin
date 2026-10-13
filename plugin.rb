# frozen_string_literal: true
# name: discourse-professional-network
# about: Member-approved LinkedIn PDF profile imports and selected LinkedIn links
# version: 0.8.0
# authors: Illyrian Brains
# url: https://github.com/IllyrianBrains/network-plugin
# required_version: 3.2.0

enabled_site_setting :professional_network_enabled

module ::ProfessionalNetwork
  PLUGIN_NAME = "discourse-professional-network"
end

require_relative "lib/professional_network/engine"

register_asset "stylesheets/professional-network.scss"
register_svg_icon "fab-linkedin-in"
register_svg_icon "building"

after_initialize do
  # Career aspirations (ProfessionalNetwork::Aspirations) live as user custom
  # fields rather than inside Profile#data, so they can be kept out of the
  # free-form JSON a member edits directly and so return_plan/return_countries
  # can be withheld from anyone but the member and staff.
  %w[aspiration_field aspiration_subfield aspirations_note mentoring_note return_plan].each do |field|
    User.register_custom_field_type("pn_#{field}", :string)
  end
  %w[
    mentoring_interests mentoring_wanted_types mentoring_provided_types
    business_interests return_countries recommendation_priorities
  ].each do |field|
    User.register_custom_field_type("pn_#{field}", :json)
  end

  on(:post_created) do |post|
    next unless post.post_number == 1

    match = post.raw.to_s.match(%r{Original LinkedIn post:\s*(https://(?:www\.)?linkedin\.com/(?:posts/|feed/update/)[^\s<]+)}i)
    next unless match

    normalized = ProfessionalNetwork::SharedPost.normalize_url(match[1])
    next unless normalized

    source_key = Digest::SHA256.hexdigest(normalized)
    next if ProfessionalNetwork::SharedPost.exists?(user_id: post.user_id, source_key: source_key)

    ProfessionalNetwork::SharedPost.find_or_create_by!(user_id: post.user_id, topic_id: post.topic_id) do |share|
      share.source_url = normalized
      share.source_key = source_key
    end
  end
end
