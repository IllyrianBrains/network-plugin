# frozen_string_literal: true
module ProfessionalNetwork
  class City < ActiveRecord::Base
    self.table_name = "professional_network_cities"

    STATUSES = %w[active paused inactive].freeze

    validates :website_key, presence: true, format: { with: Profile::WEBSITE_KEY }
    validates :name, presence: true
    validates :slug, presence: true, format: { with: /\A[a-z0-9-]+\z/ }, uniqueness: { scope: :website_key }
    validates :status, inclusion: { in: STATUSES }

    before_validation :assign_slug

    scope :for_website, ->(website_key) { where(website_key: website_key) }
    scope :active, -> { where(status: "active") }

    # Loose matching against the free-text "city" field members already store,
    # so a profile's "Rome" can resolve to the "Roma" record and vice versa
    # without requiring every writer to agree on one spelling.
    def self.normalize_name(value)
      value.to_s.strip.downcase
    end

    def names
      ([name] + Array(aliases)).map { |value| self.class.normalize_name(value) }
    end

    private

    def assign_slug
      self.slug = self.class.normalize_name(name).parameterize if slug.blank? && name.present?
    end
  end
end
