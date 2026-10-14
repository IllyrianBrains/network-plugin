# frozen_string_literal: true
module ProfessionalNetwork
  # Serves the Ember app shell for /network/profile, the
  # member-facing LinkedIn import / mentoring / aspirations editor. Left
  # open server-side on purpose: `requires_login` here would make a
  # fresh/full page load render Discourse's generic "not found" error page
  # (with a "you need to be logged in" message baked in) instead of a clean
  # redirect to /login. The professional-network-profile(-user) routes'
  # beforeModel send anonymous visitors straight to login instead, and
  # ProfilesController/ImportsController still enforce login on the
  # underlying data.
  class ProfilePageController < BaseController
    requires_plugin ProfessionalNetwork::PLUGIN_NAME

    def show
    end
  end
end
