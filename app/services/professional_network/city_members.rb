# frozen_string_literal: true

module ProfessionalNetwork
  # Resolves which public profiles belong to a city, matching the free-text
  # "city" field members already store (plus the city's own alias list)
  # rather than requiring a hard foreign key.
  class CityMembers
    def initialize(city)
      @city = city
    end

    def profiles
      Profile.published.people.for_website(@city.website_key).includes(:user)
        .where("lower(data->>'city') = ANY (ARRAY[?]::text[])", @city.names)
    end
  end
end
