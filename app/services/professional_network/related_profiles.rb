# frozen_string_literal: true

module ProfessionalNetwork
  class RelatedProfiles
    MAX_LIMIT = 25
    HELP_MATCH_WEIGHT = 3
    MAX_RULE_SCORE = 48.0
    RULE_WEIGHT = 0.7
    COSINE_WEIGHT = 0.2
    INTERACTION_WEIGHT = 0.1
    MIN_COSINE_MATCH = 0.1
    EXPLAINABLE_COSINE = 0.15
    PRIORITY_MULTIPLIERS = [1.5, 1.3, 1.1, 0.9, 0.7, 0.5].freeze

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
      hidden_user_ids = RecommendationFeedback.for_website(@profile.website_key)
        .where(user_id: @profile.user_id, hidden: true).select(:recommended_user_id)
      candidates = Profile.published.people.for_website(@profile.website_key)
        .where.not(id: @profile.id).where.not(user_id: hidden_user_ids)
        .includes(user: :user_option).to_a
      matches = candidates.filter_map do |candidate|
        reasons = reasons_for(candidate)
        cosine = ProfileSimilarity.new(@profile, candidate).score
        next if reasons.empty? && cosine < MIN_COSINE_MATCH

        { profile: candidate, score: final_score(reasons, cosine, candidate),
          reasons: display_reasons(reasons, cosine) }
      end

      return ranked(matches) if matches.any?

      ranked(candidates.map { |candidate| fallback_match(candidate) })
    end

    private

    def ranked(matches)
      matches.sort_by { |match| [-match[:score], match[:profile].user.username_lower] }.first(@limit)
    end

    def fallback_match(profile)
      { profile: profile, score: 0.0,
        reasons: ["Discover a new connection in #{SiteSetting.professional_network_name}"] }
    end

    # Scores are percentages. Interaction quality only uses an explicit
    # helpful rating after the member requested an introduction.
    def final_score(reasons, cosine, candidate)
      weighted_rules = reasons.sum { |reason| reason[:weight] * priority_multiplier(reason[:category]) }
      rule_score = [weighted_rules / MAX_RULE_SCORE, 1.0].min
      weighted_cosine = [cosine * priority_multiplier("background"), 1.0].min
      interaction_quality = interaction_quality(candidate)
      ((RULE_WEIGHT * rule_score + COSINE_WEIGHT * weighted_cosine +
        INTERACTION_WEIGHT * interaction_quality) * 100).round(1)
    end

    def interaction_quality(candidate)
      RecommendationFeedback.for_website(@profile.website_key)
        .where(user_id: @profile.user_id, recommended_user_id: candidate.user_id, helpful: true)
        .where.not(introduction_topic_id: nil)
        .exists? ? 1.0 : 0.0
    end

    def display_reasons(reasons, cosine)
      labels = reasons.sort_by do |reason|
        -(reason[:weight] * priority_multiplier(reason[:category]))
      end.first(3).map { |reason| reason[:label] }
      labels << "Similar professional background" if labels.length < 3 && cosine >= EXPLAINABLE_COSINE
      labels
    end

    def priority_multiplier(category)
      priorities = Aspirations.new(@profile.user).recommendation_priorities
      PRIORITY_MULTIPLIERS.fetch(priorities.index(category), 1.0)
    end

    def reasons_for(candidate)
      mine = @profile.data
      other = candidate.data
      mine_aspirations = Aspirations.new(@profile.user)
      other_aspirations = Aspirations.new(candidate.user)

      reasons = []
      same(reasons, mine["city"], other["city"], 3, "location") { |value| "Same city: #{value}" }
      overlaps(reasons, mine["fields_of_expertise"], other["fields_of_expertise"], 4, "Shared field", "career")
      overlaps(reasons, mine["skills"], other["skills"], 1, "Shared skill", "background")
      overlaps(reasons, mine_aspirations.business_interests, other_aspirations.business_interests, 3,
               "Shared business interest", "opportunities", labels: Aspirations::BUSINESS_LABELS)
      reasons.concat(complementary_business_reasons(mine_aspirations, other_aspirations))
      help_match(reasons, mine["looking_for"], other["can_help_with"],
                 "May be able to help with what you're looking for", "help")
      help_match(reasons, mine["can_help_with"], other["looking_for"],
                 "You may be able to help with what they're looking for", "help")

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
        if works_in_field
          reasons << { weight: 5, category: "career", label: "Expertise in your target field: #{aspiration}" }
        end

        reasons.concat(Mentoring::ProfileMatch.new(@profile, candidate, target_field: aspiration).reasons)
      end
      reasons
    end

    def same(reasons, left, right, weight, category)
      if left.present? && right.present? && left.casecmp?(right)
        reasons << { weight: weight, category: category, label: yield(left) }
      end
    end

    def complementary_business_reasons(source, candidate)
      source_interests = source.business_interests
      candidate_interests = candidate.business_interests

      Aspirations::COMPLEMENTARY_BUSINESS_INTERESTS.filter_map do |need, match|
        counterpart = match[:counterpart]
        if source_interests.include?(need) && candidate_interests.include?(counterpart)
          { weight: 6, category: "opportunities", label: match[:label] }
        elsif source_interests.include?(counterpart) && candidate_interests.include?(need)
          { weight: 6, category: "opportunities", label: match[:reverse_label] }
        end
      end
    end

    def overlaps(reasons, left, right, weight, label, category, labels: nil)
      originals = Array(left)
      shared = values(left) & values(right)
      shared.first(2).each do |value|
        display = labels ? (labels[value] || value) : (originals.find { |item| item.to_s.casecmp?(value) } || value)
        reasons << { weight: weight, category: category, label: "#{label}: #{display}" }
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
    def help_match(reasons, seeker_text, helper_text, label, category)
      shared = significant_words(seeker_text) & significant_words(helper_text)
      return if shared.empty?

      reasons << { weight: HELP_MATCH_WEIGHT, category: category, label: "#{label}: #{shared.first}" }
    end

    def significant_words(text)
      text.to_s.downcase.scan(/[a-z]+/).uniq.reject do |word|
        word.length < 4 || HELP_STOPWORDS.include?(word)
      end
    end
  end
end
