# frozen_string_literal: true

module ProfessionalNetwork
  class DirectorySearch
    LIMIT = 100

    def initialize(website_key:, query: nil, city: nil, country: nil, field: nil, skill: nil,
                    experience_level: nil, membership_type: nil, availability: nil, open_to_consulting: nil,
                    offering_services: nil, aspiration_field: nil, aspiration_subfield: nil,
                    mentoring_interest: nil, business_interest: nil)
      @website_key = website_key
      @filters = { city: city, country: country, field: field, skill: skill,
                   experience_level: experience_level, membership_type: membership_type,
                   availability: availability }.transform_values { |value| value.to_s.strip.presence }
      @open_to_consulting = ActiveModel::Type::Boolean.new.cast(open_to_consulting)
      @offering_services = ActiveModel::Type::Boolean.new.cast(offering_services)
      @query = query.to_s.strip.first(100).presence
      @aspiration_filters = {
        field: aspiration_field,
        subfield: aspiration_subfield,
        mentoring_interest: mentoring_interest,
        business_interest: business_interest,
      }.transform_values { |value| value.to_s.strip.presence }
    end

    def results
      scope = Profile.published.for_website(@website_key).includes(user: :user_option)
      scope = exact(scope, "city", @filters[:city])
      scope = exact(scope, "country", @filters[:country])
      scope = exact(scope, "experience_level", @filters[:experience_level])
      scope = exact(scope, "membership_type", @filters[:membership_type])
      scope = exact(scope, "availability", @filters[:availability])
      scope = boolean_true(scope, "open_to_consulting") if @open_to_consulting
      scope = non_empty_array(scope, "services") if @offering_services
      scope = array_contains(scope, "fields_of_expertise", @filters[:field])
      scope = array_contains(scope, "skills", @filters[:skill])
      scope = text_search(scope, @query) if @query
      profiles = scope.order(Arel.sql("lower(professional_network_profiles.data->>'name') ASC"), :id).to_a
      profiles.select! { |profile| matches_aspirations?(profile) } if @aspiration_filters.values.any?
      profiles.first(LIMIT)
    end

    private

    def exact(scope, key, value)
      return scope unless value
      scope.where("lower(data->>?) = lower(?)", key, value)
    end

    def boolean_true(scope, key)
      scope.where("(data->>?)::boolean = true", key)
    end

    def non_empty_array(scope, key)
      scope.where("jsonb_array_length(COALESCE(data->?, '[]'::jsonb)) > 0", key)
    end

    def array_contains(scope, key, value)
      return scope unless value
      scope.where("EXISTS (SELECT 1 FROM jsonb_array_elements_text(COALESCE(data->?, '[]'::jsonb)) item WHERE lower(item) = lower(?))", key, value)
    end

    def text_search(scope, query)
      pattern = "%#{ActiveRecord::Base.sanitize_sql_like(query)}%"
      scope.where(<<~SQL.squish, pattern: pattern)
        concat_ws(' ', data->>'name', data->>'headline', data->>'company', data->>'city',
          data->>'country', data->>'about', data->>'fields_of_expertise', data->>'skills',
          data->>'experience', data->>'education', data->>'can_help_with', data->>'looking_for') ILIKE :pattern
      SQL
    end

    def matches_aspirations?(profile)
      aspirations = Aspirations.new(profile.user)
      matches_value?(aspirations.field, @aspiration_filters[:field]) &&
        matches_value?(aspirations.subfield, @aspiration_filters[:subfield]) &&
        includes_value?(aspirations.mentoring_interests, @aspiration_filters[:mentoring_interest]) &&
        includes_value?(aspirations.business_interests, @aspiration_filters[:business_interest])
    end

    def matches_value?(value, expected)
      expected.blank? || value.to_s.casecmp?(expected)
    end

    def includes_value?(values, expected)
      expected.blank? || Array(values).any? { |value| value.to_s.casecmp?(expected) }
    end
  end
end
