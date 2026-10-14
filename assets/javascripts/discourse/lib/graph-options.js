export const KIND_LABELS = {
  member: "Member",
  organization: "Organization",
  city: "City",
  field: "Field of expertise",
  group: "Group",
};
export const QUICK_FILTER_LIMIT = 6;

// Above this many participants, a force-directed layout becomes hard to read,
// so the graph waits for a filter or explicit opt-in before rendering.
export const LARGE_NETWORK_THRESHOLD = 60;

export function uniqueSortedLabels(nodes, type) {
  return [
    ...new Set(
      nodes.filter((node) => node.type === type).map((node) => node.label)
    ),
  ].sort();
}

export function topLabelsByCount(nodes, type, limit) {
  return nodes
    .filter((node) => node.type === type)
    .sort((a, b) => (b.count || 0) - (a.count || 0))
    .slice(0, limit)
    .map((node) => node.label);
}
