# frozen_string_literal: true
require "uri"

module ProfessionalNetwork
  class SharedPost < ActiveRecord::Base
    self.table_name = "professional_network_shared_posts"
    belongs_to :user
    belongs_to :topic
    validates :website_key, presence: true, format: { with: Profile::WEBSITE_KEY }

    def self.normalize_url(raw)
      uri = URI.parse(raw.to_s.strip)
      host = uri.host.to_s.downcase
      return unless uri.scheme == "https" && %w[linkedin.com www.linkedin.com].include?(host)
      return unless uri.path.start_with?("/posts/", "/feed/update/") && uri.userinfo.nil?

      uri.fragment = nil
      uri.query = nil
      uri.to_s.sub(%r{/+$}, "")
    rescue URI::InvalidURIError
      nil
    end
  end
end
