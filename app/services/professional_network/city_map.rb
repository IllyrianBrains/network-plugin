# frozen_string_literal: true

module ProfessionalNetwork
  class CityMap
    def initialize(website_key:, search: nil, field: nil, group: nil)
      @website_key = website_key
      @filters = ProfileFilters.new(search: search, field: field, group: group)
    end

    def data
      cities = City.for_website(@website_key).active.where.not(lat: nil).where.not(lng: nil).to_a
      counts = member_counts_by_city_name
      {
        cities: cities.map { |city| city_json(city, counts) },
        field_options: field_options,
        group_options: group_options,
      }
    end

    private

    def city_json(city, counts)
      {
        id: city.id, name: city.name, slug: city.slug, country: city.country,
        lat: city.lat, lng: city.lng, status: city.status,
        region: city.region, region_color: city.region_color,
        member_count: city.names.sum { |name| counts[name] || 0 }
      }
    end

    # Matches the same free-text "city" field CityMembers matches against a normalized name.
    def member_counts_by_city_name
      @filters.apply(people).each_with_object(Hash.new(0)) do |profile, counts|
        city = profile.data["city"].to_s.strip.downcase
        counts[city] += 1 if city.present?
      end
    end

    def field_options
      people.flat_map { |profile| Array(profile.data["fields_of_expertise"]) }
        .map(&:to_s).reject(&:blank?).uniq.sort
    end

    def group_options
      MemberGroups.names_by_user_id(people.map(&:user_id)).values.flatten.uniq.sort
    end

    def people
      @people ||= Profile.published.people.for_website(@website_key).includes(:user).to_a
    end
  end
end
