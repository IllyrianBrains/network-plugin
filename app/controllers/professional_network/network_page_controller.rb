# frozen_string_literal: true
module ProfessionalNetwork
  # Serves the Ember app shell for /network; the Ember
  # route registered by professional-network-route-map.js renders the actual
  # graph client-side.
  #
  # #show's body never actually runs for a normal browser page load:
  # ApplicationController's `check_xhr` before_action raises RenderEmpty for
  # any non-XHR, non-JSON GET, and that gets rescued by rendering the Ember
  # shell directly, before this action's body would execute. This controller
  # exists only so the route has somewhere to dispatch to.
  class NetworkPageController < BaseController
    requires_plugin ProfessionalNetwork::PLUGIN_NAME

    def show
    end
  end
end
