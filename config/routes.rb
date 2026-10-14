# frozen_string_literal: true

ProfessionalNetwork::Engine.routes.draw do
  get "/" => "network_page#show"
  get "/profile" => "profile_page#show"
  get "/profile/:username" => "profile_page#show", constraints: { username: RouteFormat.username }
  get "/share" => "share_page#show"
  get "/directory" => "directory_page#show"
  get "/organizations" => "organizations_page#show"
  get "/recommendations" => "recommendations_page#show"
  get "/admin" => "admin_page#show"

  defaults format: :json do
    get "profiles" => "profiles#index"
    get "directory/export" => "profiles#directory_export"
    get "profiles/:username/activity" => "activity#index", constraints: { username: RouteFormat.username }
    get "profiles/:username/related" => "profiles#related", constraints: { username: RouteFormat.username }
    get "profiles/:username" => "profiles#show", constraints: { username: RouteFormat.username }
    put "profile" => "profiles#update"
    post "profile/review" => "profiles#review"
    get "profile/export" => "profiles#export"
    post "profile/logo" => "profile_logos#create"
    delete "profile" => "profiles#destroy"
    put "profiles/:username" => "profiles#update", constraints: { username: RouteFormat.username }
    post "profiles/:username/verify" => "profiles#verify", constraints: { username: RouteFormat.username }
    delete "profiles/:username" => "profiles#destroy", constraints: { username: RouteFormat.username }
    post "imports" => "imports#create"
    get "imports/:id" => "imports#show"
    put "imports/:id" => "imports#update"
    delete "imports/:id" => "imports#destroy"
    post "imports/:id/confirm" => "imports#confirm"
    post "shares" => "shares#create"
    get "shares/:username" => "shares#index", constraints: { username: RouteFormat.username }
    get "linkedin-preview" => "linkedin_previews#show"

    get "cities" => "cities#index"
    get "cities/map" => "cities#map"
    get "cities/:slug" => "cities#show", constraints: { slug: /[a-z0-9-]+/ }

    get "network-graph" => "network_graph#index"
    get "recommendation-results" => "recommendations#index"
    get "recommendations/hidden" => "recommendations#hidden"
    put "recommendations/:username/feedback" => "recommendations#feedback",
        constraints: { username: RouteFormat.username }
    post "recommendations/:username/introduction" => "recommendations#introduction",
         constraints: { username: RouteFormat.username }

    get "admin/health" => "admin_health#show"
    get "admin/cities" => "admin_cities#index"
    post "admin/cities" => "admin_cities#create"
    put "admin/cities/:id" => "admin_cities#update"
    post "admin/cities/:id/merge" => "admin_cities#merge"
    delete "admin/cities/:id" => "admin_cities#destroy"
  end
end

Discourse::Application.routes.draw do
  mount ::ProfessionalNetwork::Engine, at: "/network"

  # Full-page loads of the Ember sub-route added by
  # professional-network-user-route-map.js need a matching Rails route, or
  # they 404 with "No route matches". Reuses core's `users#show` so the
  # normal profile shell renders and the client-side router takes over --
  # same pattern as discourse-subscriptions' "u/:username/billing".
  get "u/:username/professional-profile" => "users#show",
      constraints: {
        username: RouteFormat.username,
      }
end
