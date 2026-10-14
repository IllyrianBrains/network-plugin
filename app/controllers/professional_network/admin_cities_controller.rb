# frozen_string_literal: true

module ProfessionalNetwork
  class AdminCitiesController < BaseController
    requires_plugin ProfessionalNetwork::PLUGIN_NAME
    before_action :ensure_admin

    def index
      cities = City.for_website(website_key).order(Arel.sql("lower(name) ASC"))
      render json: { cities: cities.map { |city| city_json(city) } }
    end

    def create
      city = City.create!(city_params.merge(website_key: website_key))
      render json: { city: city_json(city) }, status: :created
    end

    def update
      city = City.for_website(website_key).find(params[:id])
      city.update!(city_params)
      render json: { city: city_json(city) }
    end

    def destroy
      City.for_website(website_key).find(params[:id]).destroy!
      head :no_content
    end

    def merge
      target = City.for_website(website_key).find(params[:id])
      source = City.for_website(website_key).find(params.require(:source_id))
      raise Discourse::InvalidParameters.new(:source_id) if source.id == target.id

      City.transaction do
        target.update!(aliases: (target.aliases + [source.name] + source.aliases).uniq)
        source.destroy!
      end
      render json: { city: city_json(target) }
    end

    private

    def ensure_admin
      raise Discourse::InvalidAccess unless guardian.is_admin?
    end

    def city_params
      params.require(:city).permit(
        :name, :slug, :country, :region, :lat, :lng, :status, :region_color,
        :image_url, :luma_url, :instagram_url, aliases: [], activities: []
      ).to_h
    end

    def city_json(city)
      city.as_json(
        only: %i[
          id name slug country region lat lng status region_color image_url luma_url instagram_url
          aliases activities created_at updated_at
        ],
      )
    end
  end
end
