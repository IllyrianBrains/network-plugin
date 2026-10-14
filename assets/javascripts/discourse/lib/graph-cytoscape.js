// Validated against the dataviz skill's accessibility checks (CVD + normal-vision
// separation, all-pairs since any two node types can sit next to each other in a
// force-directed layout). Only 3 hues clear the all-pairs floor, so "field" and
// "group" are deliberately neutral tones rather than competing hues -- their
// identity is carried by shape (round-rectangle / hexagon) and their on-canvas
// label, not by color.
const COLORS = {
  member: "#2a78d6",
  organization: "#eb6834",
  city: "#1baf7a",
  field: "#52525b",
  group: "#8a8a93",
};

export const GRAPH_LAYOUT = {
  name: "cose",
  animate: false,
  nodeRepulsion: 9000,
  idealEdgeLength: 70,
};

export function buildCytoscapeElements(nodes, edges) {
  return [
    ...nodes.map((node) => ({
      data: {
        id: node.id,
        label: node.label,
        type: node.type,
        count: node.count || 1,
        username: node.username,
      },
    })),
    ...edges.map((edge) => ({
      data: { source: edge.source, target: edge.target },
    })),
  ];
}

// City/field node size reflects how many members share them, so a hub everyone
// connects to reads differently from one with a single member.
export function buildCytoscapeStyle(nodes) {
  const maxCount = (type) =>
    Math.max(
      1.01,
      ...nodes
        .filter((node) => node.type === type)
        .map((node) => node.count || 1)
    );
  const maxCityCount = maxCount("city");
  const maxFieldCount = maxCount("field");
  const maxGroupCount = maxCount("group");

  return [
    {
      selector: "node",
      style: {
        label: "data(label)",
        "font-size": 9,
        color: "#222",
        "text-valign": "bottom",
        "text-margin-y": 4,
        "background-color": (el) => COLORS[el.data("type")] || "#888",
      },
    },
    {
      selector: "node[type = 'member']",
      style: { width: 14, height: 14 },
    },
    {
      selector: "node[type = 'organization']",
      style: { shape: "square", width: 18, height: 18 },
    },
    {
      selector: "node[type = 'city']",
      style: {
        shape: "diamond",
        width: `mapData(count, 1, ${maxCityCount}, 18, 38)`,
        height: `mapData(count, 1, ${maxCityCount}, 18, 38)`,
      },
    },
    {
      selector: "node[type = 'field']",
      style: {
        shape: "round-rectangle",
        width: `mapData(count, 1, ${maxFieldCount}, 24, 48)`,
        height: `mapData(count, 1, ${maxFieldCount}, 18, 32)`,
      },
    },
    {
      selector: "node[type = 'group']",
      style: {
        shape: "hexagon",
        width: `mapData(count, 1, ${maxGroupCount}, 20, 40)`,
        height: `mapData(count, 1, ${maxGroupCount}, 20, 40)`,
      },
    },
    {
      selector: "edge",
      style: {
        width: 1,
        "line-color": "#ccc",
        "curve-style": "haystack",
      },
    },
    { selector: ".pn-faded", style: { opacity: 0.15 } },
    { selector: ".pn-filtered", style: { display: "none" } },
  ];
}
