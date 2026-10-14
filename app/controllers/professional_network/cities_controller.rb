# frozen_string_literal: true
module ProfessionalNetwork
  class CitiesController < BaseController
    requires_plugin ProfessionalNetwork::PLUGIN_NAME

    # Matches NetworkGraph::PREVIEW_MEMBER_LIMIT -- anonymous visitors get the
    # same teaser cap on the map's city member lists as on the graph.
    PREVIEW_MEMBER_LIMIT = NetworkGraph::PREVIEW_MEMBER_LIMIT

    def index
      cities = CityDirectory.new(
        website_key: website_key, status: params[:status], region: params[:region],
        country: params[:country], query: params[:q]
      ).results
      render json: { website_key: website_key, cities: cities.map { |city| city_json(city) } }
    end

    def show
      city = City.for_website(website_key).find_by!(slug: params[:slug])
      members = CityMembers.new(
        city, search: params[:search], field: params[:field], group: params[:group]
      )
      profiles = members.profiles
      limit = current_user ? nil : PREVIEW_MEMBER_LIMIT
      visible_profiles = limit ? profiles.first(limit) : profiles
      render json: city_json(city, detailed: true).merge(
        members: visible_profiles.map do |profile|
          { username: profile.user.username, profile: ProfilePresenter.new(profile).public_profile_data }
        end,
        member_total_count: profiles.size,
        member_limit: limit,
      )
    end

    def map
      data = CityMap.new(
        website_key: website_key, search: params[:search], field: params[:field], group: params[:group]
      ).data
      render json: { website_key: website_key }.merge(data)
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
