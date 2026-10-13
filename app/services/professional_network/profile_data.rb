# frozen_string_literal: true

require "date"
require "uri"

module ProfessionalNetwork
  class ProfileData
    LIST_FIELDS = %w[
      fields_of_expertise skills languages certifications preferred_locations organization_locations
      organization_needs organization_offerings organization_opportunities collaboration_interests
    ].freeze
    COLLECTION_FIELDS = %w[
      experience education volunteering honors services organization_projects organization_opportunity_details
    ].freeze
    URL_FIELDS = %w[
      website linkedin_url avatar profile_url github_url twitter_url portfolio_url calendar_url contact_url
      logo_url instagram_url
    ].freeze
    BOOLEAN_FIELDS = %w[
      open_to_work hiring open_to_consulting open_to_introductions open_to_collaboration
      open_to_speaking open_to_volunteering open_to_relocation
    ].freeze
    ENUM_FIELDS = {
      "availability" => %w[full_time part_time not_available],
      "experience_level" => %w[student junior mid senior expert],
      "contact_preference" => %w[discourse linkedin email],
      "meeting_preference" => %w[online in_person either],
      "organization_type" => %w[
        business ngo professional_network community association foundation social_enterprise
        education_research public_institution other
      ],
    }.freeze
    TEXT_LIMIT = 5_000
    LIST_LIMIT = 50
    ENTRY_LIMIT = 30
    FORUM_USERNAME = /\A[a-z0-9_.-]{1,60}\z/i
    OPPORTUNITY_KINDS = %w[job internship event project volunteer benefit collaboration mentoring].freeze

    def self.normalize(data)
      data = data.deep_stringify_keys
      validate_shape!(data)
      data.transform_values do |value|
        case value
        when String then value.strip.first(TEXT_LIMIT)
        when Array then normalize_array(value)
        when Hash then normalize_hash(value)
        else value
        end
      end.tap do |normalized|
        validate_urls!(normalized)
        validate_opportunities!(normalized["organization_opportunity_details"])
      end
    end

    def self.validate_shape!(data)
      LIST_FIELDS.each { |key| invalid!(key) if data.key?(key) && !data[key].is_a?(Array) }
      COLLECTION_FIELDS.each { |key| invalid!(key) if data.key?(key) && !data[key].is_a?(Array) }
      BOOLEAN_FIELDS.each { |key| invalid!(key) if data.key?(key) && ![true, false].include?(data[key]) }
      ENUM_FIELDS.each { |key, allowed| invalid!(key) if data[key].present? && !allowed.include?(data[key]) }
      if data["business_username"].present?
        invalid!("business_username") unless data["business_username"].is_a?(String) && data["business_username"].match?(FORUM_USERNAME)
      end
      if LIST_FIELDS.any? { |key| Array(data[key]).length > LIST_LIMIT } ||
          COLLECTION_FIELDS.any? { |key| Array(data[key]).length > ENTRY_LIMIT }
        raise Discourse::InvalidParameters.new(:data)
      end
    end

    def self.normalize_array(values)
      values.filter_map do |value|
        item = value.is_a?(Hash) ? normalize_hash(value) : value.to_s.strip.first(TEXT_LIMIT)
        item.presence
      end.uniq
    end

    def self.normalize_hash(value)
      value.deep_stringify_keys.transform_values do |item|
        case item
        when Array then normalize_array(item)
        when String then item.strip.first(TEXT_LIMIT)
        when Numeric, TrueClass, FalseClass, NilClass then item
        else item.to_s.strip.first(TEXT_LIMIT)
        end
      end
    end

    def self.validate_urls!(data)
      URL_FIELDS.each do |key|
        next if data[key].blank?
        invalid!(key) unless data[key].is_a?(String)
        uri = URI.parse(data[key])
        invalid!(key) unless %w[http https].include?(uri.scheme) && uri.host.present? && uri.userinfo.nil?
      rescue URI::InvalidURIError
        invalid!(key)
      end
    end

    def self.validate_opportunities!(opportunities)
      Array(opportunities).each do |opportunity|
        invalid!("organization_opportunity_details") unless opportunity.is_a?(Hash)
        kind = opportunity["kind"]
        invalid!("organization_opportunity_details") if opportunity["title"].blank? || !OPPORTUNITY_KINDS.include?(kind)
        validate_date!(opportunity["expires_on"])
        validate_nested_url!(opportunity["url"])
      end
    end

    def self.validate_date!(value)
      return if value.blank?
      invalid!("organization_opportunity_details") unless value.is_a?(String) && value.match?(/\A\d{4}-\d{2}-\d{2}\z/)
      Date.iso8601(value)
    rescue Date::Error
      invalid!("organization_opportunity_details")
    end

    def self.validate_nested_url!(value)
      return if value.blank?
      invalid!("organization_opportunity_details") unless value.is_a?(String)
      uri = URI.parse(value)
      invalid!("organization_opportunity_details") unless %w[http https].include?(uri.scheme) && uri.host.present? && uri.userinfo.nil?
    rescue URI::InvalidURIError
      invalid!("organization_opportunity_details")
    end

    def self.invalid!(key)
      raise Discourse::InvalidParameters.new(key.to_sym)
    end

    private_class_method :validate_shape!, :normalize_array, :normalize_hash, :validate_urls!,
                         :validate_opportunities!, :validate_date!, :validate_nested_url!, :invalid!
  end
end
