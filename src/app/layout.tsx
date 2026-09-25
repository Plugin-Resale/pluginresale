import type { Metadata } from "next";
import { Bricolage_Grotesque, IBM_Plex_Mono, IBM_Plex_Sans } from "next/font/google";
import { Analytics } from "@vercel/analytics/next";
import { SpeedInsights } from "@vercel/speed-insights/next";
import { Footer } from "@/components/Footer";
import { Header } from "@/components/Header";
import "./globals.css";

const display = Bricolage_Grotesque({
  variable: "--font-display",
  subsets: ["latin"],
});

const body = IBM_Plex_Sans({
  variable: "--font-body",
  subsets: ["latin"],
  weight: ["400", "500", "600"],
});

const mono = IBM_Plex_Mono({
  variable: "--font-mono",
  subsets: ["latin"],
  weight: ["400", "500"],
});

export const metadata: Metadata = {
  // The site is served on www (the bare domain redirects there): canonical and og:url must match.
  metadataBase: new URL("https://www.pluginresale.com"),
  title: {
    default: "Plugin Resale — Buy and sell used audio plugin licenses",
    template: "%s · Plugin Resale",
  },
  description:
    "The free marketplace for second-hand audio plugin licenses. No fees, no commission, with every developer's transfer rules in one place.",
  // Link previews. No title here: a page without its own og:title falls back to its <title>.
  // A page that sets its own `openGraph` replaces this whole object, so it must repeat
  // siteName/type and have its own opengraph-image next to it.
  openGraph: { type: "website", siteName: "Plugin Resale" },
  twitter: { card: "summary_large_image" },
};

export default function RootLayout({ children }: LayoutProps<"/">) {
  return (
    <html lang="en" className={`${display.variable} ${body.variable} ${mono.variable}`}>
      <body>
        <Header />
        {children}
        <Footer />
        <Analytics />
        <SpeedInsights />
      </body>
    </html>
  );
}
