# frozen_string_literal: true
module ProfessionalNetwork
  class Profile < ActiveRecord::Base
    self.table_name = "professional_network_profiles"
    belongs_to :user

    WEBSITE_KEY = /\A[a-z0-9](?:[a-z0-9.-]{0,61}[a-z0-9])?\z/
    PROFILE_TYPES = %w[person organization].freeze
    validates :website_key, presence: true, format: { with: WEBSITE_KEY }
    validates :profile_type, inclusion: { in: PROFILE_TYPES }
    validate :profile_type_cannot_change, on: :update

    scope :for_website, ->(website_key) { where(website_key: website_key) }
    scope :published, -> { where(public_profile: true) }
    scope :people, -> { where(profile_type: "person") }
    scope :organizations, -> { where(profile_type: "organization") }

    private

    def profile_type_cannot_change
      errors.add(:profile_type, "cannot be changed") if will_save_change_to_profile_type?
    end
  end
end
