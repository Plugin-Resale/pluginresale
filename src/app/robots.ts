import type { MetadataRoute } from "next";

export default function robots(): MetadataRoute.Robots {
  return {
    rules: {
      userAgent: "*",
      allow: "/",
      // Private pages: signed-in only, nothing for a search engine there.
      disallow: ["/account", "/deals/", "/auth/", "/listings/*/messages"],
    },
    sitemap: "https://www.pluginresale.com/sitemap.xml",
  };
}
