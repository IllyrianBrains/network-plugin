# frozen_string_literal: true

module ProfessionalNetwork
  # Builds the node/edge graph behind the website's member network visualization:
  # member -> city and member -> field-of-expertise edges, for public profiles only.
  class NetworkGraph
    MAX_MEMBERS = 300

    def initialize(website_key:)
      @website_key = website_key
    end

    def data
      nodes = []
      edges = []
      seen = {}

      profiles.each do |profile|
        username = profile.user.username
        nodes << { id: "member:#{username}", type: "member", label: profile.data["name"].presence || username }

        city = profile.data["city"].to_s.strip
        add_edge(nodes, edges, seen, "city", city, "member:#{username}") if city.present?

        Array(profile.data["fields_of_expertise"]).each do |field|
          add_edge(nodes, edges, seen, "field", field, "member:#{username}")
        end
      end

      { nodes: nodes, edges: edges }
    end

    private

    def profiles
      Profile.published.for_website(@website_key).includes(:user).limit(MAX_MEMBERS)
    end

    def add_edge(nodes, edges, seen, type, label, member_node_id)
      return if label.blank?
      node_id = "#{type}:#{label.downcase}"
      unless seen[node_id]
        nodes << { id: node_id, type: type, label: label }
        seen[node_id] = true
      end
      edges << { source: member_node_id, target: node_id }
    end
  end
end
