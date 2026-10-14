# frozen_string_literal: true

module ProfessionalNetwork
  class BusinessAccountLink
    def self.validate!(usernames:, owner:, website_key:)
      Array(usernames).each do |username|
        validate_username!(username, owner, website_key)
      end
    end

    def self.validate_username!(username, owner, website_key)
      return if username.blank?

      account = User.find_by(username_lower: username.downcase)
      profile =
        account &&
          Profile.organizations.find_by(
            user_id: account.id,
            website_key: website_key,
          )
      if account.nil? || account.id == owner.id || profile.nil?
        raise Discourse::InvalidParameters.new(:organization_usernames)
      end
    end

    private_class_method :validate_username!
  end
end
