# frozen_string_literal: true

require "csv"

module ProfessionalNetwork
  class CityImporter
    FIELDS = %w[name country region lat lng aliases status region_color].freeze

    def initialize(path:, website_key: "default")
      @path = path
      @website_key = website_key
      @created = 0
      @updated = 0
    end

    def import!
      validate_website_key!
      CSV.foreach(@path, headers: true).with_index(2) do |row, line_number|
        import_row(row, line_number)
      end
      { created: @created, updated: @updated }
    end

    private

    def validate_website_key!
      return if @website_key.match?(Profile::WEBSITE_KEY)

      raise ArgumentError, "invalid website key"
    end

    def import_row(row, line_number)
      name = row["name"].to_s.strip
      raise ArgumentError, "city name missing on CSV line #{line_number}" if name.blank?

      slug = row["slug"].to_s.strip.presence || name.parameterize
      city = City.find_or_initialize_by(website_key: @website_key, slug: slug)
      was_new = city.new_record?
      city.assign_attributes(attributes(row).merge(name: name))
      city.save!
      was_new ? @created += 1 : @updated += 1
    rescue ActiveRecord::RecordInvalid => error
      raise ArgumentError, "invalid city on CSV line #{line_number}: #{error.record.errors.full_messages.join(", ")}"
    end

    def attributes(row)
      FIELDS.each_with_object({}) do |field, result|
        value = row[field]
        next if value.nil?

        result[field] = normalized_value(field, value)
      end
    end

    def normalized_value(field, value)
      stripped = value.to_s.strip
      return stripped.split("|").map(&:strip).reject(&:blank?).uniq if field == "aliases"
      return stripped.presence if %w[lat lng].include?(field)
      return stripped.downcase.presence || "active" if field == "status"

      stripped
    end
  end
end
