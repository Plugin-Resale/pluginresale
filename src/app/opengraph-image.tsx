import { ogImage } from "@/lib/og";

export const alt = "Plugin Resale, the free marketplace for used audio plugin licenses";
export const size = { width: 1200, height: 630 };
export const contentType = "image/png";

export default async function Image() {
  return ogImage({
    eyebrow: "Second-hand plugin licenses",
    title: "Your unused plugins are money sleeping.",
  });
}
