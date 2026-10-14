# frozen_string_literal: true
module ProfessionalNetwork
  class NetworkGraphController < BaseController
    requires_plugin ProfessionalNetwork::PLUGIN_NAME

    def index
      graph = NetworkGraph.new(website_key: website_key, preview: current_user.blank?)
      render json: { website_key: website_key }.merge(graph.data)
    end
  end
end
