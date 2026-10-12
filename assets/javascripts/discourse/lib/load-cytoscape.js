import loadScript from "discourse/lib/load-script";

let cytoscapePromise;

export default function loadCytoscape() {
  cytoscapePromise ??= loadScript(
    "/plugins/discourse-professional-network/javascripts/cytoscape-3.30.2.min.js"
  );
  return cytoscapePromise;
}
