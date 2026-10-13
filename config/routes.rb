# frozen_string_literal: true

ProfessionalNetwork::Engine.routes.draw do
  get "/" => "network_page#show"
  get "/profile" => "profile_page#show"
  get "/profile/:username" => "profile_page#show", constraints: { username: RouteFormat.username }
  get "/share" => "share_page#show"
  get "/directory" => "directory_page#show"
  get "/organizations" => "directory_page#show"
  get "/recommendations" => "recommendations_page#show"

  defaults format: :json do
    get "profiles" => "profiles#index"
    get "profiles/:username/activity" => "activity#index", constraints: { username: RouteFormat.username }
    get "profiles/:username/related" => "profiles#related", constraints: { username: RouteFormat.username }
    get "profiles/:username" => "profiles#show", constraints: { username: RouteFormat.username }
    put "profile" => "profiles#update"
    delete "profile" => "profiles#destroy"
    put "profiles/:username" => "profiles#update", constraints: { username: RouteFormat.username }
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
