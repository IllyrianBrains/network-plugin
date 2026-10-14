# frozen_string_literal: true

module ProfessionalNetwork
  class AdminPageController < BaseController
    requires_plugin ProfessionalNetwork::PLUGIN_NAME
    requires_login
    before_action :ensure_admin

    def show
    end

    private

    def ensure_admin
      raise Discourse::InvalidAccess unless guardian.is_admin?
    end
  end
end
