import type { MetadataRoute } from "next";

export default function robots(): MetadataRoute.Robots {
  return {
    rules: {
      userAgent: "*",
      allow: "/",
      // Private pages (/signin, /account, /sell, /deals, message threads) are kept out of Google
      // with a noindex tag instead: a page blocked here can still be indexed from links, since
      // Google never gets to read its noindex. /auth/ only holds redirect handlers, no pages.
      disallow: ["/auth/"],
    },
    sitemap: "https://www.pluginresale.com/sitemap.xml",
  };
}
