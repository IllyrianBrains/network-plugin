# frozen_string_literal: true
module ProfessionalNetwork
  # Serves the Ember app shell for /network/profile, the
  # member-facing LinkedIn import / mentoring / aspirations editor.
  #
  # #show's body never actually runs for a normal browser page load:
  # ApplicationController's `check_xhr` before_action raises RenderEmpty for
  # any non-XHR, non-JSON GET and that gets rescued by rendering the Ember
  # shell directly, before this action's body executes. `requires_login`
  # hooks into `block_if_requires_login`, which (unlike `check_xhr`) runs
  # early enough in the filter chain to actually gate anonymous access.
  class ProfilePageController < BaseController
    requires_login

    def show
    end
  end
end
