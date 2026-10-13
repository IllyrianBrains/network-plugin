# frozen_string_literal: true

module ProfessionalNetwork
  class BusinessAccountLink
    def self.validate!(username:, owner:)
      return if username.blank?

      account = User.find_by(username_lower: username.downcase)
      if account.nil? || account.id == owner.id
        raise Discourse::InvalidParameters.new(:business_username)
      end
    end
  end
end
