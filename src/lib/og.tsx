import { readFile } from "node:fs/promises";
import path from "node:path";
import { ImageResponse } from "next/og";

// Link-preview images (Instagram, Facebook, WhatsApp, iMessage...), 1200×630, in the site's colours.
// ImageResponse needs static TTF files, not the site's web fonts: they live in assets/fonts.

export const OG_SIZE = { width: 1200, height: 630 };

const INK = "#17171b";
const MUTED = "#55545c";
const ACCENT = "#c2410c";

const FONT_DIR = path.join(process.cwd(), "assets", "fonts");

async function loadFonts() {
  const [display, mono, body] = await Promise.all([
    readFile(path.join(FONT_DIR, "BricolageGrotesque-Bold.ttf")),
    readFile(path.join(FONT_DIR, "IBMPlexMono-Medium.ttf")),
    readFile(path.join(FONT_DIR, "IBMPlexSans-Regular.ttf")),
  ]);
  return [
    { name: "Display", data: display, weight: 700 as const, style: "normal" as const },
    { name: "Mono", data: mono, weight: 500 as const, style: "normal" as const },
    { name: "Body", data: body, weight: 400 as const, style: "normal" as const },
  ];
}

// Same wording and colours as <TransferBadge>.
function Badge({ transferable }: { transferable: boolean | null }) {
  const [label, color, background] =
    transferable === null
      ? ["Policy not verified", "#7a4b00", "#fbefd2"]
      : transferable
        ? ["Transferable", "#1f6b44", "#e1f0e6"]
        : ["Not transferable", "#9a3412", "#fdeae1"];
  return (
    <div
      style={{
        display: "flex",
        fontFamily: "Body",
        fontSize: 30,
        color,
        background,
        padding: "10px 26px",
        borderRadius: 99,
      }}
    >
      {label}
    </div>
  );
}

// Long names get a smaller title so they still fit on two lines.
function titleSize(title: string) {
  if (title.length <= 16) return 104;
  if (title.length <= 28) return 84;
  if (title.length <= 48) return 68;
  return 56;
}

export async function ogImage({
  eyebrow,
  title,
  price,
  transferable,
  footer = "Free to list, free to buy, no commission",
}: {
  eyebrow?: string;
  title: string;
  price?: string;
  transferable?: boolean | null;
  footer?: string;
}) {
  return new ImageResponse(
    (
      <div
        style={{
          width: "100%",
          height: "100%",
          display: "flex",
          flexDirection: "column",
          justifyContent: "space-between",
          padding: "64px 72px",
          background: "#f2efe8",
          color: INK,
        }}
      >
        <div style={{ display: "flex", fontFamily: "Display", fontSize: 44 }}>
          <span>plugin</span>
          <span style={{ color: ACCENT }}>resale</span>
        </div>

        <div style={{ display: "flex", flexDirection: "column" }}>
          {eyebrow && (
            <div
              style={{
                display: "flex",
                fontFamily: "Mono",
                fontSize: 28,
                letterSpacing: 3,
                color: ACCENT,
                marginBottom: 18,
              }}
            >
              {eyebrow.toUpperCase()}
            </div>
          )}
          <div
            style={{
              display: "flex",
              fontFamily: "Display",
              fontSize: titleSize(title),
              lineHeight: 1.05,
              letterSpacing: -2,
              maxWidth: 1056,
            }}
          >
            {title}
          </div>
          {(price || transferable !== undefined) && (
            <div style={{ display: "flex", alignItems: "center", gap: 28, marginTop: 30 }}>
              {price && (
                <div style={{ display: "flex", fontFamily: "Mono", fontSize: 64, color: INK }}>
                  {price}
                </div>
              )}
              {transferable !== undefined && <Badge transferable={transferable} />}
            </div>
          )}
        </div>

        <div
          style={{
            display: "flex",
            justifyContent: "space-between",
            fontFamily: "Body",
            fontSize: 28,
            color: MUTED,
            borderTop: "2px solid #d9d4c9",
            paddingTop: 26,
          }}
        >
          <span>{footer}</span>
          <span style={{ fontFamily: "Mono", color: INK }}>pluginresale.com</span>
        </div>
      </div>
    ),
    { ...OG_SIZE, fonts: await loadFonts() },
  );
}
