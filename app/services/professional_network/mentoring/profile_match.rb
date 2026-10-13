# frozen_string_literal: true

module ProfessionalNetwork
  module Mentoring
    class ProfileMatch
      WEIGHT = 6

      def initialize(source_profile, candidate_profile, target_field:)
        @source_profile = source_profile
        @candidate_profile = candidate_profile
        @target_field = target_field.to_s.strip
      end

      def reasons
        return [] if @target_field.blank? || !candidate_works_in_target_field?

        source = Preferences.new(@source_profile.user)
        candidate = Preferences.new(@candidate_profile.user)
        return [] unless source.seeking? && candidate.offering?

        [{ weight: WEIGHT, category: "mentoring", label: "Open to mentoring in #{@target_field}" }]
      end

      private

      def candidate_works_in_target_field?
        target = @target_field.downcase
        Array(@candidate_profile.data["fields_of_expertise"]).any? do |value|
          field = value.to_s.strip.downcase
          next false if field.blank?
          next field == target if field.length < 3 || target.length < 3

          target.include?(field) || field.include?(target)
        end
      end
    end
  end
end
