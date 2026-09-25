import type { NextConfig } from "next";

const nextConfig: NextConfig = {
  // Blog posts are Markdown files read from disk at request time: ship them with the blog routes.
  // The link-preview image of a post also reads its photo from public/blog.
  outputFileTracingIncludes: {
    "/blog": ["./content/blog/**/*"],
    "/blog/**": ["./content/blog/**/*", "./public/blog/**/*"],
  },
};

export default nextConfig;
