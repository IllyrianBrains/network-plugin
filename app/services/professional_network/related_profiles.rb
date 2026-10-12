# frozen_string_literal: true

module ProfessionalNetwork
  class RelatedProfiles
    MAX_LIMIT = 25
    HELP_MATCH_WEIGHT = 3

    # Common words excluded when comparing free-text "can_help_with" and
    # "looking_for" fields, so two unrelated members don't match just
    # because both wrote "help" or "looking for".
    HELP_STOPWORDS = %w[
      with that this your their from have been about them into would could
      which some will need want help looking connect connection someone
      anyone people person work working great like such being over under
      what else here there just only very also know able find
    ].freeze

    def initialize(profile, limit: nil)
      @profile = profile
      @limit = [[limit.to_i.nonzero? || 10, 1].max, MAX_LIMIT].min
    end

    def results
      Profile.published.for_website(@profile.website_key).where.not(id: @profile.id).includes(user: :user_option).filter_map do |candidate|
        reasons = reasons_for(candidate)
        next if reasons.empty?
        { profile: candidate, score: reasons.sum { |reason| reason[:weight] },
          reasons: reasons.sort_by { |reason| -reason[:weight] }.first(3).map { |reason| reason[:label] } }
      end.sort_by { |match| [-match[:score], match[:profile].user.username_lower] }.first(@limit)
    end

    private

    def reasons_for(candidate)
      mine = @profile.data
      other = candidate.data
      mine_aspirations = Aspirations.new(@profile.user)
      other_aspirations = Aspirations.new(candidate.user)

      reasons = []
      same(reasons, mine["city"], other["city"], 3) { |value| "Same city: #{value}" }
      overlaps(reasons, mine["fields_of_expertise"], other["fields_of_expertise"], 4, "Shared field")
      overlaps(reasons, mine["skills"], other["skills"], 1, "Shared skill")
      overlaps(reasons, mine_aspirations.business_interests, other_aspirations.business_interests, 3,
               "Shared business interest", labels: Aspirations::BUSINESS_LABELS)
      reasons.concat(complementary_business_reasons(mine_aspirations, other_aspirations))
      help_match(reasons, mine["looking_for"], other["can_help_with"],
                 "May be able to help with what you're looking for")
      help_match(reasons, mine["can_help_with"], other["looking_for"],
                 "You may be able to help with what they're looking for")

      aspiration = mine_aspirations.field.to_s.strip
      if aspiration.present?
        # A target field like "Engineering Leadership" rarely exact-matches a
        # tag like "engineering" or "leadership", so match on containment
        # either way rather than requiring the two strings to be identical.
        aspiration_downcased = aspiration.downcase
        works_in_field = values(other["fields_of_expertise"]).any? do |field|
          next field == aspiration_downcased if field.length < 3 || aspiration_downcased.length < 3
          aspiration_downcased.include?(field) || field.include?(aspiration_downcased)
        end
        reasons << { weight: 5, label: "Expertise in your target field: #{aspiration}" } if works_in_field

        reasons.concat(Mentoring::ProfileMatch.new(@profile, candidate, target_field: aspiration).reasons)
      end
      reasons
    end

    def same(reasons, left, right, weight)
      reasons << { weight: weight, label: yield(left) } if left.present? && right.present? && left.casecmp?(right)
    end

    def complementary_business_reasons(source, candidate)
      source_interests = source.business_interests
      candidate_interests = candidate.business_interests

      Aspirations::COMPLEMENTARY_BUSINESS_INTERESTS.filter_map do |need, match|
        counterpart = match[:counterpart]
        if source_interests.include?(need) && candidate_interests.include?(counterpart)
          { weight: 6, label: match[:label] }
        elsif source_interests.include?(counterpart) && candidate_interests.include?(need)
          { weight: 6, label: match[:reverse_label] }
        end
      end
    end

    def overlaps(reasons, left, right, weight, label, labels: nil)
      originals = Array(left)
      shared = values(left) & values(right)
      shared.first(2).each do |value|
        display = labels ? (labels[value] || value) : (originals.find { |item| item.to_s.casecmp?(value) } || value)
        reasons << { weight: weight, label: "#{label}: #{display}" }
      end
    end

    def values(value)
      Array(value).filter_map { |item| item.to_s.strip.downcase.presence }
    end

    # Matches one member's free-text "what I'm looking for" against
    # another's free-text "what I can help with" (or vice versa), on shared
    # significant words -- these fields have no fixed vocabulary, so this
    # is the closest the network graph can get to seeker/offerer matching
    # for them without introducing a tagging system.
    def help_match(reasons, seeker_text, helper_text, label)
      shared = significant_words(seeker_text) & significant_words(helper_text)
      return if shared.empty?

      reasons << { weight: HELP_MATCH_WEIGHT, label: "#{label}: #{shared.first}" }
    end

    def significant_words(text)
      text.to_s.downcase.scan(/[a-z]+/).uniq.reject do |word|
        word.length < 4 || HELP_STOPWORDS.include?(word)
      end
    end
  end
end
