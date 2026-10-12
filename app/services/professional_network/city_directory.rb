# frozen_string_literal: true

module ProfessionalNetwork
  class CityDirectory
    def initialize(website_key:, status: nil, region: nil, country: nil, query: nil)
      @website_key = website_key
      @status = status.to_s.strip.presence
      @region = region.to_s.strip.presence
      @country = country.to_s.strip.presence
      @query = query.to_s.strip.first(100).presence
    end

    def results
      scope = City.for_website(@website_key)
      scope = scope.where(status: @status) if @status
      scope = scope.where("lower(region) = lower(?)", @region) if @region
      scope = scope.where("lower(country) = lower(?)", @country) if @country
      scope = scope.where(
        "name ILIKE :pattern OR country ILIKE :pattern",
        pattern: "%#{ActiveRecord::Base.sanitize_sql_like(@query)}%"
      ) if @query
      scope.order(Arel.sql("lower(name) ASC"))
    end
  end
end
