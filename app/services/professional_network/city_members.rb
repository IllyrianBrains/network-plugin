# frozen_string_literal: true

module ProfessionalNetwork
  # Resolves which public profiles belong to a city, matching the free-text
  # "city" field members already store (plus the city's own alias list)
  # rather than requiring a hard foreign key.
  class CityMembers
    def initialize(city, search: nil, field: nil, group: nil)
      @city = city
      @filters = ProfileFilters.new(search: search, field: field, group: group)
    end

    def profiles
      @filters.apply(
        Profile.published.people.for_website(@city.website_key).includes(:user)
          .where("lower(data->>'city') = ANY (ARRAY[?]::text[])", @city.names)
      )
    end
  end
end
