const LINKEDIN_HOSTS = ["linkedin.com", "www.linkedin.com"];
const LINKEDIN_PATH_PREFIXES = ["/posts/", "/feed/update/"];

// Mirrors ProfessionalNetwork::SharedPost.normalize_url so the share form can
// reject an unusable link before it even reaches the server.
export function normalizeLinkedInShareUrl(raw) {
  let url;
  try {
    url = new URL((raw || "").trim());
  } catch {
    return null;
  }

  if (url.protocol !== "https:" || url.username || url.password) {
    return null;
  }
  if (!LINKEDIN_HOSTS.includes(url.hostname.toLowerCase())) {
    return null;
  }
  if (
    !LINKEDIN_PATH_PREFIXES.some((prefix) => url.pathname.startsWith(prefix))
  ) {
    return null;
  }

  url.search = "";
  url.hash = "";
  return url.toString().replace(/\/+$/, "");
}
