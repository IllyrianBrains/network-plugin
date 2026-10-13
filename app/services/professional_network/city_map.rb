# frozen_string_literal: true

module ProfessionalNetwork
  class CityMap
    def initialize(website_key:)
      @website_key = website_key
    end

    def data
      cities = City.for_website(@website_key).active.where.not(lat: nil).where.not(lng: nil).to_a
      counts = member_counts_by_city_name
      cities.map do |city|
        {
          id: city.id, name: city.name, slug: city.slug, country: city.country,
          lat: city.lat, lng: city.lng, status: city.status,
          region: city.region, region_color: city.region_color,
          member_count: city.names.sum { |name| counts[name] || 0 }
        }
      end
    end

    private

    # Grouped in one query instead of one CityMembers lookup per city, since
    # both match the same free-text "city" field against a normalized name.
    def member_counts_by_city_name
      Profile.published.people.for_website(@website_key)
        .where("data->>'city' IS NOT NULL")
        .group("lower(data->>'city')")
        .count
    end
  end
end
