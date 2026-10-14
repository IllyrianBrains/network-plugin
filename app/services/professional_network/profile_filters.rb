# frozen_string_literal: true

module ProfessionalNetwork
  # The search/field-of-expertise/group filters exposed on the network graph, applied
  # here to a loaded set of published Profile records (with :user included) so the city
  # map and city member list can offer the same filters.
  class ProfileFilters
    def initialize(search: nil, field: nil, group: nil)
      @search = search.to_s.strip.downcase.presence
      @field = field.to_s.strip.downcase.presence
      @group = group.to_s.strip.presence
    end

    def apply(profiles)
      profiles = profiles.to_a
      profiles = profiles.select { |profile| matches_search?(profile) } if @search
      profiles = profiles.select { |profile| matches_field?(profile) } if @field
      profiles = filter_by_group(profiles) if @group
      profiles
    end

    private

    def matches_search?(profile)
      name = profile.data["name"].to_s.downcase
      headline = profile.data["headline"].to_s.downcase
      username = profile.user.username.to_s.downcase
      name.include?(@search) || headline.include?(@search) || username.include?(@search)
    end

    def matches_field?(profile)
      Array(profile.data["fields_of_expertise"]).any? { |value| value.to_s.downcase == @field }
    end

    def filter_by_group(profiles)
      groups_by_user_id = MemberGroups.names_by_user_id(profiles.map(&:user_id))
      profiles.select { |profile| groups_by_user_id[profile.user_id].include?(@group) }
    end
  end
end
