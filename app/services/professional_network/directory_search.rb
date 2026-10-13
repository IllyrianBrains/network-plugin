# frozen_string_literal: true

module ProfessionalNetwork
  class DirectorySearch
    LIMIT = 100

    def initialize(website_key:, profile_type: "person", query: nil, city: nil, country: nil, field: nil, skill: nil,
                    experience_level: nil, membership_type: nil, availability: nil, open_to_consulting: nil,
                    offering_services: nil, aspiration_field: nil, aspiration_subfield: nil,
                    mentoring_interest: nil, business_interest: nil, organization_type: nil,
                    sector: nil, stage: nil, collaboration_interest: nil, offers_mentoring: nil,
                    include_unpublished: false)
      @website_key = website_key
      @profile_type = profile_type.presence || "person"
      raise Discourse::InvalidParameters.new(:profile_type) unless Profile::PROFILE_TYPES.include?(@profile_type)
      @filters = { city: city, country: country, field: field, skill: skill,
                   experience_level: experience_level, membership_type: membership_type,
                   availability: availability, organization_type: organization_type,
                   sector: sector, stage: stage,
                   collaboration_interest: collaboration_interest }.transform_values { |value| value.to_s.strip.presence }
      @open_to_consulting = ActiveModel::Type::Boolean.new.cast(open_to_consulting)
      @offering_services = ActiveModel::Type::Boolean.new.cast(offering_services)
      @offers_mentoring = ActiveModel::Type::Boolean.new.cast(offers_mentoring)
      @include_unpublished = ActiveModel::Type::Boolean.new.cast(include_unpublished)
      @query = query.to_s.strip.first(100).presence
      @aspiration_filters = {
        field: aspiration_field,
        subfield: aspiration_subfield,
        mentoring_interest: mentoring_interest,
        business_interest: business_interest,
      }.transform_values { |value| value.to_s.strip.presence }
    end

    def results
      scope = Profile.for_website(@website_key).where(profile_type: @profile_type)
      scope = scope.published unless @include_unpublished
      scope = scope.includes(user: :user_option)
      scope = partial(scope, "city", @filters[:city])
      scope = partial(scope, "country", @filters[:country])
      scope = exact(scope, "experience_level", @filters[:experience_level])
      scope = exact(scope, "membership_type", @filters[:membership_type])
      scope = exact(scope, "availability", @filters[:availability])
      scope = exact(scope, "organization_type", @filters[:organization_type])
      scope = partial(scope, "sector", @filters[:sector])
      scope = partial(scope, "stage", @filters[:stage])
      scope = boolean_true(scope, "open_to_consulting") if @open_to_consulting
      scope = non_empty_array(scope, "services") if @offering_services
      scope = opportunity_kind(scope, "mentoring") if @offers_mentoring
      scope = array_contains_partial(scope, "fields_of_expertise", @filters[:field])
      scope = array_contains_partial(scope, "skills", @filters[:skill])
      scope = array_contains_partial(scope, "collaboration_interests", @filters[:collaboration_interest])
      scope = text_search(scope, @query) if @query
      profiles = scope.order(Arel.sql("lower(professional_network_profiles.data->>'name') ASC"), :id).to_a
      profiles.select! { |profile| matches_aspirations?(profile) } if @profile_type == "person" && @aspiration_filters.values.any?
      profiles.first(LIMIT)
    end

    private

    def exact(scope, key, value)
      return scope unless value
      scope.where("lower(data->>?) = lower(?)", key, value)
    end

    # City, country, sector, etc. are free text with no fixed vocabulary -- members
    # can't be expected to type the exact stored value, so these filters match a substring.
    def partial(scope, key, value)
      return scope unless value
      scope.where("data->>? ILIKE ?", key, "%#{ActiveRecord::Base.sanitize_sql_like(value)}%")
    end

    def boolean_true(scope, key)
      scope.where("(data->>?)::boolean = true", key)
    end

    def non_empty_array(scope, key)
      scope.where("jsonb_array_length(COALESCE(data->?, '[]'::jsonb)) > 0", key)
    end

    def array_contains_partial(scope, key, value)
      return scope unless value
      scope.where(
        "EXISTS (SELECT 1 FROM jsonb_array_elements_text(COALESCE(data->?, '[]'::jsonb)) item WHERE item ILIKE ?)",
        key, "%#{ActiveRecord::Base.sanitize_sql_like(value)}%"
      )
    end

    def opportunity_kind(scope, kind)
      scope.where(<<~SQL.squish, kind)
        EXISTS (
          SELECT 1 FROM jsonb_array_elements(COALESCE(data->'organization_opportunity_details', '[]'::jsonb)) item
          WHERE item->>'kind' = ?
        )
      SQL
    end

    def text_search(scope, query)
      pattern = "%#{ActiveRecord::Base.sanitize_sql_like(query)}%"
      scope.where(<<~SQL.squish, pattern: pattern)
        concat_ws(' ', data->>'name', data->>'headline', data->>'company', data->>'city',
          data->>'country', data->>'about', data->>'fields_of_expertise', data->>'skills',
          data->>'experience', data->>'education', data->>'can_help_with', data->>'looking_for',
          data->>'services', data->>'mission', data->>'sector', data->>'organization_needs',
          data->>'organization_offerings', data->>'organization_opportunities',
          data->>'collaboration_interests', data->>'organization_projects',
          data->>'organization_opportunity_details') ILIKE :pattern
      SQL
    end

    def matches_aspirations?(profile)
      aspirations = Aspirations.new(profile.user)
      partial_match?(aspirations.field, @aspiration_filters[:field]) &&
        partial_match?(aspirations.subfield, @aspiration_filters[:subfield]) &&
        includes_value?(aspirations.mentoring_interests, @aspiration_filters[:mentoring_interest]) &&
        includes_value?(aspirations.business_interests, @aspiration_filters[:business_interest])
    end

    # Aspiration field/subfield are free text, same reasoning as #partial above.
    def partial_match?(value, expected)
      expected.blank? || value.to_s.downcase.include?(expected.downcase)
    end

    def includes_value?(values, expected)
      expected.blank? || Array(values).any? { |value| value.to_s.casecmp?(expected) }
    end
  end
end
