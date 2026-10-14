# frozen_string_literal: true
module ProfessionalNetwork
  class Profile < ActiveRecord::Base
    self.table_name = "professional_network_profiles"
    belongs_to :user
    belongs_to :logo_upload, class_name: "Upload", optional: true
    has_many :upload_references, as: :target, dependent: :destroy

    WEBSITE_KEY = /\A[a-z0-9](?:[a-z0-9.-]{0,61}[a-z0-9])?\z/
    PROFILE_TYPES = %w[person organization].freeze
    validates :website_key, presence: true, format: { with: WEBSITE_KEY }
    validates :profile_type, inclusion: { in: PROFILE_TYPES }
    validate :profile_type_cannot_change, on: :update

    scope :for_website, ->(website_key) { where(website_key: website_key) }
    scope :published, -> { where(public_profile: true) }
    scope :people, -> { where(profile_type: "person") }
    scope :organizations, -> { where(profile_type: "organization") }

    def stale?
      (reviewed_at || updated_at) < 6.months.ago
    end

    # A profile row can exist with every field still at its blank default
    # (e.g. right after an import draft is confirmed) -- matching/recommending
    # off that is pointless, so callers that need "has the member actually
    # filled anything in" should check this rather than just `present?`.
    def data_present?
      data.present? && data.any? { |_, value| self.class.value_present?(value) }
    end

    def self.value_present?(value)
      case value
      when Array then value.any? { |item| item.to_s.strip.present? }
      when String then value.strip.present?
      when TrueClass, FalseClass then false
      else value.present?
      end
    end

    private

    def profile_type_cannot_change
      errors.add(:profile_type, "cannot be changed") if will_save_change_to_profile_type?
    end
  end
end
