# frozen_string_literal: true
module ProfessionalNetwork
  class Profile < ActiveRecord::Base
    self.table_name = "professional_network_profiles"
    belongs_to :user

    WEBSITE_KEY = /\A[a-z0-9](?:[a-z0-9.-]{0,61}[a-z0-9])?\z/
    validates :website_key, presence: true, format: { with: WEBSITE_KEY }

    scope :for_website, ->(website_key) { where(website_key: website_key) }
    scope :published, -> { where(public_profile: true) }
  end
end
