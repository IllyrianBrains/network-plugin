# frozen_string_literal: true
module ProfessionalNetwork
  class ImportDraft < ActiveRecord::Base
    self.table_name = "professional_network_import_drafts"
    belongs_to :user
    validates :website_key, presence: true, format: { with: Profile::WEBSITE_KEY }
  end
end
