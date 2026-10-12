# frozen_string_literal: true

module ProfessionalNetwork
  # Wraps a Discourse User's career-aspiration answers, business interests,
  # and private return plans. Mentoring preferences are composed into this
  # compatibility facade so the existing profile API can keep one payload.
  # Values use namespaced user custom fields rather than the editable profile
  # JSON document.
  #
  # `return_plan`/`return_countries` are the private half: #public_h never
  # includes them, so callers that serialize to anyone other than the member
  # themselves or staff must use #public_h alone (see ProfilesController).
  class Aspirations
    MENTORING_INTERESTS = Mentoring::Preferences::INTERESTS
    BUSINESS_INTERESTS = %w[
      cofounder_intro client_partner_intro job_opportunities hiring_candidates
      project_funding investment_opportunities
    ].freeze
    RETURN_PLANS = %w[yes maybe no already_there].freeze
    RETURN_COUNTRIES = %w[albania kosovo].freeze

    # Human-readable labels for the coded values above, used wherever a
    # match reason needs to say something friendlier than "cofounder_intro".
    BUSINESS_LABELS = {
      "cofounder_intro" => "introduction to a co-founder",
      "client_partner_intro" => "introduction to clients/partners",
      "job_opportunities" => "job opportunities",
      "hiring_candidates" => "candidates to hire",
      "project_funding" => "funding for a project/business",
      "investment_opportunities" => "investment opportunities",
    }.freeze

    COMPLEMENTARY_BUSINESS_INTERESTS = {
      "job_opportunities" => {
        counterpart: "hiring_candidates",
        label: "Looking for candidates",
        reverse_label: "Looking for job opportunities",
      },
      "project_funding" => {
        counterpart: "investment_opportunities",
        label: "Interested in investing",
        reverse_label: "Looking for project or business funding",
      },
    }.freeze

    # Within MENTORING_INTERESTS: which answers mean "I'm looking for this"
    # vs. "I can offer this" -- used to match seekers with offerers.
    SEEKING_MENTORING = Mentoring::Preferences::SEEKING
    OFFERING_MENTORING = Mentoring::Preferences::OFFERING

    FIELD_LIMIT = 120
    SUBFIELD_LIMIT = 120
    NOTE_LIMIT = 1000

    attr_reader :user

    def initialize(user)
      @user = user
    end

    def field
      user.custom_fields["pn_aspiration_field"]
    end

    def subfield
      user.custom_fields["pn_aspiration_subfield"]
    end

    def mentoring_interests
      mentoring_preferences.interests
    end

    def mentoring_wanted_types
      mentoring_preferences.wanted_types
    end

    def mentoring_provided_types
      mentoring_preferences.provided_types
    end

    def business_interests
      Array(user.custom_fields["pn_business_interests"])
    end

    def note
      user.custom_fields["pn_aspirations_note"]
    end

    def return_plan
      user.custom_fields["pn_return_plan"]
    end

    def return_countries
      Array(user.custom_fields["pn_return_countries"])
    end

    def seeking_mentoring?
      mentoring_preferences.seeking?
    end

    def offering_mentoring?
      mentoring_preferences.offering?
    end

    def blank?
      field.blank? && subfield.blank? && mentoring_interests.empty? &&
        mentoring_wanted_types.empty? && mentoring_provided_types.empty? &&
        mentoring_preferences.note.blank? &&
        business_interests.empty? && note.blank?
    end

    # Safe to show to anyone viewing this member's public profile or the
    # directory.
    def public_h
      return {} if blank?
      mentoring_preferences.public_h.merge(
        "field" => field, "subfield" => subfield,
        "business_interests" => business_interests.presence,
        "note" => note,
      ).compact
    end

    # Only for the member themselves or staff -- never merge this into a
    # response that anyone else can see.
    def private_h
      { "return_plan" => return_plan, "return_countries" => return_countries.presence }.compact
    end

    # Applies a normalized attribute hash (string keys matching the readers
    # above). Call #save! to persist. Partial: keys not present are left
    # untouched, so the editor can save one section at a time.
    def assign(attrs)
      self.class.validate!(attrs)
      mentoring_preferences.assign(attrs)
      attrs.each do |key, value|
        case key
        when "field"
          user.custom_fields["pn_aspiration_field"] = value.to_s.strip.first(FIELD_LIMIT)
        when "subfield"
          user.custom_fields["pn_aspiration_subfield"] = value.to_s.strip.first(SUBFIELD_LIMIT)
        when "business_interests"
          user.custom_fields["pn_business_interests"] = Array(value).map(&:to_s).uniq
        when "note"
          user.custom_fields["pn_aspirations_note"] = value.to_s.strip.first(NOTE_LIMIT)
        when "return_plan"
          user.custom_fields["pn_return_plan"] = value.presence
        when "return_countries"
          user.custom_fields["pn_return_countries"] = Array(value).map(&:to_s).uniq
        end
      end
    end

    def save!
      user.save_custom_fields
    end

    def self.validate!(attrs)
      Mentoring::Preferences.validate!(attrs)
      if attrs.key?("business_interests") && (Array(attrs["business_interests"]).map(&:to_s) - BUSINESS_INTERESTS).any?
        raise Discourse::InvalidParameters.new(:business_interests)
      end
      if attrs["return_plan"].present? && !RETURN_PLANS.include?(attrs["return_plan"])
        raise Discourse::InvalidParameters.new(:return_plan)
      end
      if attrs.key?("return_countries") && (Array(attrs["return_countries"]).map(&:to_s) - RETURN_COUNTRIES).any?
        raise Discourse::InvalidParameters.new(:return_countries)
      end
      raise Discourse::InvalidParameters.new(:subfield) if attrs["subfield"].to_s.length > SUBFIELD_LIMIT
      raise Discourse::InvalidParameters.new(:note) if attrs["note"].to_s.length > NOTE_LIMIT
    end

    private

    def mentoring_preferences
      @mentoring_preferences ||= Mentoring::Preferences.new(user)
    end
  end
end
