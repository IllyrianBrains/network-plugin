# frozen_string_literal: true

module ProfessionalNetwork
  module Mentoring
    class Preferences
      INTERESTS = %w[mentor_connection career_coaching mentoring_opportunity].freeze
      TYPES = %w[project_guidance career_orientation technical_skills workshops].freeze
      SEEKING = %w[mentor_connection career_coaching].freeze
      OFFERING = %w[mentoring_opportunity].freeze
      NOTE_LIMIT = 1000

      attr_reader :user

      def initialize(user)
        @user = user
      end

      def interests
        Array(user.custom_fields["pn_mentoring_interests"])
      end

      def wanted_types
        Array(user.custom_fields["pn_mentoring_wanted_types"])
      end

      def provided_types
        Array(user.custom_fields["pn_mentoring_provided_types"])
      end

      def note
        user.custom_fields["pn_mentoring_note"]
      end

      def seeking?
        (interests & SEEKING).any?
      end

      def offering?
        (interests & OFFERING).any?
      end

      def public_h
        {
          "mentoring_interests" => interests.presence,
          "mentoring_wanted_types" => wanted_types.presence,
          "mentoring_provided_types" => provided_types.presence,
          "mentoring_note" => note.presence,
        }.compact
      end

      def assign(attrs)
        assign_values(attrs, "mentoring_interests", INTERESTS)
        assign_values(attrs, "mentoring_wanted_types", TYPES)
        assign_values(attrs, "mentoring_provided_types", TYPES)
        if attrs.key?("mentoring_note")
          raise Discourse::InvalidParameters.new(:mentoring_note) if attrs["mentoring_note"].to_s.length > NOTE_LIMIT
          user.custom_fields["pn_mentoring_note"] = attrs["mentoring_note"].to_s.strip
        end
      end

      def self.validate!(attrs)
        validate_values!(attrs, "mentoring_interests", INTERESTS)
        validate_values!(attrs, "mentoring_wanted_types", TYPES)
        validate_values!(attrs, "mentoring_provided_types", TYPES)
        if attrs["mentoring_note"].to_s.length > NOTE_LIMIT
          raise Discourse::InvalidParameters.new(:mentoring_note)
        end
      end

      private

      def assign_values(attrs, key, allowed)
        return unless attrs.key?(key)

        values = self.class.validate_values!(attrs, key, allowed)
        user.custom_fields["pn_#{key}"] = values.uniq
      end

      def self.validate_values!(attrs, key, allowed)
        return [] unless attrs.key?(key)

        values = Array(attrs[key]).map(&:to_s)
        raise Discourse::InvalidParameters.new(key.to_sym) if (values - allowed).any?

        values
      end
    end
  end
end
