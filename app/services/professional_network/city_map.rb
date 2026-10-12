# frozen_string_literal: true

module ProfessionalNetwork
  class CityMap
    def initialize(website_key:)
      @website_key = website_key
    end

    def data
      City.for_website(@website_key).map do |city|
        {
          id: city.id, name: city.name, slug: city.slug, country: city.country,
          lat: city.lat, lng: city.lng, status: city.status,
          region: city.region, region_color: city.region_color,
          member_count: CityMembers.new(city).profiles.count
        }
      end
    end
  end
end
