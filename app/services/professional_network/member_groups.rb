# frozen_string_literal: true

module ProfessionalNetwork
  # Public (visibility_level: public), non-automatic group names per user -- shared by
  # every service that lets an unauthenticated visitor filter the member network by
  # Discourse group, since automatic groups (trust levels, staff, "everyone", ...) aren't
  # a meaningful filter and private groups must not leak membership to the public.
  class MemberGroups
    def self.names_by_user_id(user_ids)
      GroupUser.joins(:group)
        .where(user_id: user_ids)
        .where(groups: { automatic: false, visibility_level: Group.visibility_levels[:public] })
        .pluck(:user_id, "groups.name")
        .each_with_object(Hash.new { |hash, key| hash[key] = [] }) do |(user_id, name), memo|
          memo[user_id] << name
        end
    end
  end
end
