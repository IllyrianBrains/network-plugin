# frozen_string_literal: true
module ProfessionalNetwork
  class NetworkGraphController < BaseController
    def index
      render json: { website_key: website_key }.merge(NetworkGraph.new(website_key: website_key).data)
    end
  end
end
