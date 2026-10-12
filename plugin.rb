# frozen_string_literal: true
# name: discourse-professional-network
# about: Member-approved LinkedIn PDF profile imports and selected LinkedIn links
# version: 0.8.0
# authors: Illyrian Brains
# required_version: 3.2.0

enabled_site_setting :professional_network_enabled

module ::ProfessionalNetwork
  PLUGIN_NAME = "discourse-professional-network"
end

require_relative "app/models/professional_network/profile"
require_relative "app/models/professional_network/import_draft"
require_relative "app/models/professional_network/shared_post"
require_relative "app/models/professional_network/city"
require_relative "app/services/professional_network/pdf_parser"
require_relative "app/services/professional_network/profile_data"
require_relative "app/services/professional_network/directory_search"
require_relative "app/services/professional_network/mentoring/preferences"
require_relative "app/services/professional_network/mentoring/profile_match"
require_relative "app/services/professional_network/related_profiles"
require_relative "app/services/professional_network/aspirations"
require_relative "app/services/professional_network/city_directory"
require_relative "app/services/professional_network/city_members"
require_relative "app/services/professional_network/city_map"
require_relative "app/services/professional_network/network_graph"

register_asset "stylesheets/professional-network.scss"
register_svg_icon "linkedin"

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
    business_interests return_countries
  ].each do |field|
    User.register_custom_field_type("pn_#{field}", :json)
  end

  require_relative "app/controllers/professional_network/base_controller"
  require_relative "app/controllers/professional_network/profiles_controller"
  require_relative "app/controllers/professional_network/imports_controller"
  require_relative "app/controllers/professional_network/shares_controller"
  require_relative "app/controllers/professional_network/activity_controller"
  require_relative "app/controllers/professional_network/cities_controller"
  require_relative "app/controllers/professional_network/network_graph_controller"
  require_relative "app/controllers/professional_network/network_page_controller"
  require_relative "app/controllers/professional_network/profile_page_controller"
  require_relative "app/controllers/professional_network/directory_page_controller"

  Discourse::Application.routes.append do
    get "/professional-network/network" => "professional_network/network_page#show"
    get "/professional-network/profile" => "professional_network/profile_page#show"
    get "/professional-network/directory" => "professional_network/directory_page#show"

    scope "/professional-network", module: :professional_network, defaults: { format: :json } do
      get "profiles" => "profiles#index"
      get "profiles/:username/activity" => "activity#index", constraints: { username: RouteFormat.username }
      get "profiles/:username/related" => "profiles#related", constraints: { username: RouteFormat.username }
      get "profiles/:username" => "profiles#show", constraints: { username: RouteFormat.username }
      put "profile" => "profiles#update"
      post "imports" => "imports#create"
      get "imports/:id" => "imports#show"
      put "imports/:id" => "imports#update"
      delete "imports/:id" => "imports#destroy"
      post "imports/:id/confirm" => "imports#confirm"
      post "shares" => "shares#create"
      get "shares/:username" => "shares#index", constraints: { username: RouteFormat.username }

      get "cities" => "cities#index"
      get "cities/map" => "cities#map"
      get "cities/:slug" => "cities#show", constraints: { slug: /[a-z0-9-]+/ }

      get "network-graph" => "network_graph#index"
    end
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
