import loadScript from "discourse/lib/load-script";

const SCRIPT_URL =
  "/plugins/discourse-professional-network/javascripts/openlayers-10.7.0.min.js";
const STYLESHEET_URL =
  "/plugins/discourse-professional-network/javascripts/openlayers-10.7.0.css";

let openLayersPromise;

function loadStylesheet() {
  if (document.querySelector(`link[href="${STYLESHEET_URL}"]`)) {
    return;
  }

  const link = document.createElement("link");
  link.rel = "stylesheet";
  link.href = STYLESHEET_URL;
  document.head.appendChild(link);
}

export default function loadOpenLayers() {
  loadStylesheet();
  openLayersPromise ??= loadScript(SCRIPT_URL);
  return openLayersPromise;
}
