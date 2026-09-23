// Temporary landing page until the real Home is built (build order step 4).
export default function Home() {
  return (
    <main
      style={{
        minHeight: "calc(100dvh - 65px)",
        display: "grid",
        placeItems: "center",
        padding: "24px 16px",
      }}
    >
      <div style={{ maxWidth: 560, textAlign: "center" }}>
        <p
          style={{
            fontFamily: "var(--font-mono)",
            fontSize: 13,
            textTransform: "uppercase",
            letterSpacing: "0.08em",
            color: "var(--accent)",
            margin: 0,
          }}
        >
          Coming soon
        </p>
        <h1 style={{ fontSize: "clamp(40px, 8vw, 64px)", margin: "12px 0 16px" }}>
          Plugin Resale
        </h1>
        <p style={{ color: "var(--muted)", fontSize: 18, margin: 0 }}>
          The free marketplace for second-hand audio plugin licenses. No fees, no
          commission — and every developer&apos;s transfer rules in one place.
        </p>
        <p style={{ marginTop: 32, fontSize: 15 }}>
          <a href="mailto:contact@pluginresale.com">contact@pluginresale.com</a>
        </p>
      </div>
    </main>
  );
}
