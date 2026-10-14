# frozen_string_literal: true

module ProfessionalNetwork
  # Left open server-side on purpose: `requires_login` here would make a
  # fresh/full page load render Discourse's generic "not found" error page
  # (with a "you need to be logged in" message baked in) instead of a clean
  # redirect to /login. The professional-network-recommendations route's
  # beforeModel sends anonymous visitors straight to login instead, and
  # RecommendationsController still enforces login on the underlying data.
  class RecommendationsPageController < BaseController
    requires_plugin ProfessionalNetwork::PLUGIN_NAME

    def show
    end
  end
end
