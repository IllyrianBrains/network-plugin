# frozen_string_literal: true
module ProfessionalNetwork
  # Serves the Ember app shell for /network/organizations; see
  # NetworkPageController for why #show's body never actually runs. Unlike
  # DirectoryPageController (the member directory), this stays open to
  # anonymous visitors -- the organizations directory is a public tab.
  class OrganizationsPageController < BaseController
    requires_plugin ProfessionalNetwork::PLUGIN_NAME

    def show
    end
  end
end
