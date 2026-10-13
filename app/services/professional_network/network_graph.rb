# frozen_string_literal: true

module ProfessionalNetwork
  # Builds the node/edge graph behind the website's network visualization: member and
  # organization profiles, linked to shared city/field (or city/sector) hubs, plus a
  # direct member -> organization edge where the member's profile names that business.
  # Public (published) profiles only.
  class NetworkGraph
    MAX_MEMBERS = 300
    MAX_ORGANIZATIONS = 150

    def initialize(website_key:)
      @website_key = website_key
    end

    def data
      nodes = []
      edges = []
      node_index = {}
      organization_usernames = {}

      organizations.each do |profile|
        username = profile.user.username
        nodes << { id: "organization:#{username}", type: "organization",
                    label: profile.data["name"].presence || username, username: username }
        organization_usernames[username.downcase] = username

        city = profile.data["city"].to_s.strip
        add_edge(nodes, edges, node_index, "city", city, "organization:#{username}") if city.present?

        sector = profile.data["sector"].to_s.strip
        add_edge(nodes, edges, node_index, "field", sector, "organization:#{username}") if sector.present?
      end

      people.each do |profile|
        username = profile.user.username
        nodes << { id: "member:#{username}", type: "member", label: profile.data["name"].presence || username,
                    username: username }

        city = profile.data["city"].to_s.strip
        add_edge(nodes, edges, node_index, "city", city, "member:#{username}") if city.present?

        Array(profile.data["fields_of_expertise"]).each do |field|
          add_edge(nodes, edges, node_index, "field", field, "member:#{username}")
        end

        # Only link to an organization actually present in this graph (published, same
        # website) -- a business_username that doesn't resolve shouldn't fabricate a node.
        org_username = organization_usernames[profile.data["business_username"].to_s.strip.downcase]
        edges << { source: "member:#{username}", target: "organization:#{org_username}" } if org_username
      end

      { nodes: nodes, edges: edges }
    end

    private

    def people
      Profile.published.people.for_website(@website_key).includes(:user).limit(MAX_MEMBERS)
    end

    def organizations
      Profile.published.organizations.for_website(@website_key).includes(:user).limit(MAX_ORGANIZATIONS)
    end

    # `count` is how many members/organizations share that city/field -- the frontend uses
    # it to size those nodes, so a hub everyone connects to doesn't look the same as one
    # with a single member.
    def add_edge(nodes, edges, node_index, type, label, source_node_id)
      return if label.blank?
      node_id = "#{type}:#{label.downcase}"
      node = node_index[node_id]
      unless node
        node = { id: node_id, type: type, label: label, count: 0 }
        nodes << node
        node_index[node_id] = node
      end
      node[:count] += 1
      edges << { source: source_node_id, target: node_id }
    end
  end
end
