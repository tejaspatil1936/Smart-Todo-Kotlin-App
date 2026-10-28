// INK design tokens for the Tailwind CDN build used by every screens/*/code.html.
// Values mirror BUILD-SPEC.md §2 exactly. Load after cdn.tailwindcss.com.
tailwind.config = {
  theme: {
    extend: {
      colors: {
        ground: "#0C0C0C",
        surface: "#161616",
        raised: "#1E1E1E",
        hairline: "#262626",
        stroke: "#333333",
        disabled: "#5C5C5C",
        muted: "#A3A3A3",
        ink: "#F5F5F5",
        inv: "#F5F5F5",
        "on-inv": "#0C0C0C",
        "on-inv-2": "#4A4A4A",
        track: "#E4E4E4",
      },
      fontFamily: {
        sans: ["Instrument Sans", "system-ui", "sans-serif"],
        mono: ["JetBrains Mono", "ui-monospace", "monospace"],
      },
      fontSize: {
        display: ["104px", { lineHeight: "1", letterSpacing: "-0.04em" }],
        title: ["28px", { lineHeight: "36px", letterSpacing: "-0.01em" }],
        heading: ["20px", { lineHeight: "28px" }],
        body: ["15px", { lineHeight: "22px" }],
        label: ["13px", { lineHeight: "16px", letterSpacing: "0.08em" }],
        caption: ["12px", { lineHeight: "16px" }],
        rail: ["15px", { lineHeight: "22px" }],
      },
      spacing: {
        gutter: "24px",
        rail: "88px",
      },
      borderRadius: {
        card: "16px",
        sheet: "24px",
      },
    },
  },
};
