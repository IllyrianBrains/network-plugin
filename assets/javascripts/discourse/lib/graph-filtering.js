const PARTICIPANT_SELECTOR = "[type = 'member'], [type = 'organization']";
const HUB_SELECTOR = "[type = 'city'], [type = 'field']";

// Hides member/organization nodes that don't match the current search/city/field filters
// (and any city/field hub left with no visible participants), via a `pn-filtered` class
// the cytoscape stylesheet maps to `display: none`. Returns the number of still-visible
// members and organizations.
export function applyGraphFilters(cy, { search, cityFilter, fieldFilter }) {
  const query = search.trim().toLowerCase();

  cy.elements().removeClass("pn-filtered");

  const hiddenParticipants = cy.nodes(PARTICIPANT_SELECTOR).filter((node) => {
    if (query && !node.data("label").toLowerCase().includes(query)) {
      return true;
    }
    const neighbors = node.connectedEdges().connectedNodes().not(node);
    if (
      cityFilter &&
      !neighbors.some(
        (neighbor) =>
          neighbor.data("type") === "city" &&
          neighbor.data("label") === cityFilter
      )
    ) {
      return true;
    }
    if (
      fieldFilter &&
      !neighbors.some(
        (neighbor) =>
          neighbor.data("type") === "field" &&
          neighbor.data("label") === fieldFilter
      )
    ) {
      return true;
    }
    return false;
  });

  hiddenParticipants.addClass("pn-filtered");
  hiddenParticipants.connectedEdges().addClass("pn-filtered");
  cy.nodes(HUB_SELECTOR).forEach((node) => {
    if (
      !node.connectedEdges().filter((edge) => !edge.hasClass("pn-filtered"))
        .length
    ) {
      node.addClass("pn-filtered");
    }
  });

  return cy.nodes(PARTICIPANT_SELECTOR).not(".pn-filtered").length;
}
