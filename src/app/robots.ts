import type { MetadataRoute } from "next";

export default function robots(): MetadataRoute.Robots {
  return {
    rules: [
      {
        userAgent: "*",
        allow: "/",
        // Private pages (/signin, /account, /sell, /deals, message threads) are kept out of Google
        // with a noindex tag instead: a page blocked here can still be indexed from links, since
        // Google never gets to read its noindex. /auth/ only holds redirect handlers, no pages.
        disallow: ["/auth/"],
      },
      // Meta AI training crawler: thousands of requests a day, used up most of the Vercel CPU quota
      // (Oct 2026). Link previews on Instagram/Facebook use facebookexternalhit, which stays allowed.
      { userAgent: "meta-externalagent", disallow: "/" },
      // SEO-tool and AI crawlers that bring no visitors: in the Vercel request logs of 5 Nov 2026
      // they made ~60% of the page requests served by functions (MJ12bot alone ~1,200 a day).
      // 9 Nov 2026: SERankingBacklinksBot loaded /signin 568 times in 5 hours (29% of all requests)
      // and Amzn-SearchBot (a different token from Amazonbot) rendered ~130 uncached plugin pages.
      {
        userAgent: [
          "MJ12bot",
          "DotBot",
          "AhrefsBot",
          "SemrushBot",
          "SERankingBacklinksBot",
          "Amazonbot",
          "Amzn-SearchBot",
          "ElevenlabsCrawler",
          "Reflectionbot",
          "ExaSearchBot",
          "GPTBot",
          "CCBot",
          "Bytespider",
        ],
        disallow: "/",
      },
    ],
    sitemap: "https://www.pluginresale.com/sitemap.xml",
  };
}
