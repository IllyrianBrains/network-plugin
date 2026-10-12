# frozen_string_literal: true
module ProfessionalNetwork
  class CitiesController < BaseController
    def index
      cities = CityDirectory.new(
        website_key: website_key, status: params[:status], region: params[:region],
        country: params[:country], query: params[:q]
      ).results
      render json: { website_key: website_key, cities: cities.map { |city| city_json(city) } }
    end

    def show
      city = City.for_website(website_key).find_by!(slug: params[:slug])
      members = CityMembers.new(city)
      render json: city_json(city, detailed: true).merge(
        members: members.profiles.map { |profile| { username: profile.user.username, profile: profile.data } }
      )
    end

    def map
      render json: { website_key: website_key, cities: CityMap.new(website_key: website_key).data }
    end

    private

    def city_json(city, detailed: false)
      base = {
        id: city.id, name: city.name, slug: city.slug, country: city.country,
        lat: city.lat, lng: city.lng, status: city.status, region: city.region,
        region_color: city.region_color, image_url: city.image_url
      }
      return base unless detailed
      base.merge(luma_url: city.luma_url, instagram_url: city.instagram_url, activities: city.activities)
    end
  end
end
