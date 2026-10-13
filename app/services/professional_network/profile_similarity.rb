# frozen_string_literal: true

module ProfessionalNetwork
  # Computes local cosine similarity from public professional profile text.
  # This deliberately uses no external embedding or AI service.
  class ProfileSimilarity
    TEXT_FIELDS = %w[
      headline company about fields_of_expertise skills industry current_role
      can_help_with looking_for ideal_connection
    ].freeze
    ASPIRATION_FIELDS = %w[field subfield business_interests].freeze
    STOPWORDS = %w[
      about after also and are been can for from have into its our that the
      their them they this with you your
    ].freeze

    def initialize(source_profile, candidate_profile)
      @source_profile = source_profile
      @candidate_profile = candidate_profile
    end

    def score
      source = term_frequency(@source_profile)
      candidate = term_frequency(@candidate_profile)
      return 0.0 if source.empty? || candidate.empty?

      dot_product = source.sum { |term, count| count * candidate.fetch(term, 0) }
      magnitude = vector_length(source) * vector_length(candidate)
      magnitude.zero? ? 0.0 : dot_product / magnitude
    end

    private

    def term_frequency(profile)
      aspirations = Aspirations.new(profile.user).public_h
      values = TEXT_FIELDS.flat_map { |field| Array(profile.data[field]) }
      values.concat(ASPIRATION_FIELDS.flat_map { |field| Array(aspirations[field]) })

      values.join(" ").downcase.scan(/[[:alnum:]]+/).each_with_object(Hash.new(0)) do |term, counts|
        counts[term] += 1 if term.length >= 3 && STOPWORDS.exclude?(term)
      end
    end

    def vector_length(vector)
      Math.sqrt(vector.values.sum { |count| count**2 })
    end
  end
end
