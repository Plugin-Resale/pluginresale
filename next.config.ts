import type { NextConfig } from "next";

const nextConfig: NextConfig = {
  // Blog posts are Markdown files read from disk at request time: ship them with the blog routes.
  outputFileTracingIncludes: {
    "/blog": ["./content/blog/**/*"],
    "/blog/*": ["./content/blog/**/*"],
  },
};

export default nextConfig;
