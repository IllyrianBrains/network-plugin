# frozen_string_literal: true

require "uri"

module ProfessionalNetwork
  class ProfileData
    LIST_FIELDS = %w[fields_of_expertise skills languages certifications preferred_locations].freeze
    COLLECTION_FIELDS = %w[experience education volunteering honors services].freeze
    URL_FIELDS = %w[
      website linkedin_url avatar profile_url github_url twitter_url portfolio_url calendar_url
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
    }.freeze
    TEXT_LIMIT = 5_000
    LIST_LIMIT = 50
    ENTRY_LIMIT = 30

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
      end.tap { |normalized| validate_urls!(normalized) }
    end

    def self.validate_shape!(data)
      LIST_FIELDS.each { |key| invalid!(key) if data.key?(key) && !data[key].is_a?(Array) }
      COLLECTION_FIELDS.each { |key| invalid!(key) if data.key?(key) && !data[key].is_a?(Array) }
      BOOLEAN_FIELDS.each { |key| invalid!(key) if data.key?(key) && ![true, false].include?(data[key]) }
      ENUM_FIELDS.each { |key, allowed| invalid!(key) if data[key].present? && !allowed.include?(data[key]) }
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
        uri = URI.parse(data[key])
        invalid!(key) unless %w[http https].include?(uri.scheme) && uri.host.present? && uri.userinfo.nil?
      rescue URI::InvalidURIError
        invalid!(key)
      end
    end

    def self.invalid!(key)
      raise Discourse::InvalidParameters.new(key.to_sym)
    end

    private_class_method :validate_shape!, :normalize_array, :normalize_hash, :validate_urls!, :invalid!
  end
end
