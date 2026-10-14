# frozen_string_literal: true
module ProfessionalNetwork
  # Serves the Ember app shell for /network/directory; see
  # NetworkPageController for why #show's body never actually runs. Left
  # open server-side on purpose: `requires_login` here would make a
  # fresh/full page load render Discourse's generic "not found" error page
  # (with a "you need to be logged in" message baked in) instead of a clean
  # redirect to /login. The professional-network-directory route's
  # beforeModel sends anonymous visitors straight to login instead, and
  # ProfilesController#index still enforces login on the underlying data for
  # anything other than the organizations directory.
  class DirectoryPageController < BaseController
    requires_plugin ProfessionalNetwork::PLUGIN_NAME

    def show
    end
  end
end
