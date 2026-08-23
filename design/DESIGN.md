---
name: INK
colors:
  surface: '#141313'
  surface-dim: '#141313'
  surface-bright: '#3a3939'
  surface-container-lowest: '#0e0e0e'
  surface-container-low: '#1c1b1b'
  surface-container: '#201f1f'
  surface-container-high: '#2a2a2a'
  surface-container-highest: '#353434'
  on-surface: '#e5e2e1'
  on-surface-variant: '#c4c7c8'
  inverse-surface: '#e5e2e1'
  inverse-on-surface: '#313030'
  outline: '#8e9192'
  outline-variant: '#444748'
  surface-tint: '#c6c6c7'
  primary: '#ffffff'
  on-primary: '#2f3131'
  primary-container: '#e2e2e2'
  on-primary-container: '#636565'
  inverse-primary: '#5d5f5f'
  secondary: '#c7c6c6'
  on-secondary: '#2f3131'
  secondary-container: '#484949'
  on-secondary-container: '#b8b8b8'
  tertiary: '#ffffff'
  on-tertiary: '#342f2d'
  tertiary-container: '#eae1dd'
  on-tertiary-container: '#696360'
  error: '#ffb4ab'
  on-error: '#690005'
  error-container: '#93000a'
  on-error-container: '#ffdad6'
  primary-fixed: '#e2e2e2'
  primary-fixed-dim: '#c6c6c7'
  on-primary-fixed: '#1a1c1c'
  on-primary-fixed-variant: '#454747'
  secondary-fixed: '#e3e2e2'
  secondary-fixed-dim: '#c7c6c6'
  on-secondary-fixed: '#1a1c1c'
  on-secondary-fixed-variant: '#464747'
  tertiary-fixed: '#eae1dd'
  tertiary-fixed-dim: '#cec5c1'
  on-tertiary-fixed: '#1f1b19'
  on-tertiary-fixed-variant: '#4b4643'
  background: '#141313'
  on-background: '#e5e2e1'
  surface-variant: '#353434'
typography:
  display:
    fontFamily: Instrument Sans
    fontSize: 48px
    fontWeight: '600'
    lineHeight: 56px
    letterSpacing: -0.02em
  title-lg:
    fontFamily: Instrument Sans
    fontSize: 32px
    fontWeight: '600'
    lineHeight: 40px
    letterSpacing: -0.01em
  title-lg-mobile:
    fontFamily: Instrument Sans
    fontSize: 28px
    fontWeight: '600'
    lineHeight: 36px
  heading:
    fontFamily: Instrument Sans
    fontSize: 20px
    fontWeight: '500'
    lineHeight: 28px
  body:
    fontFamily: Instrument Sans
    fontSize: 16px
    fontWeight: '400'
    lineHeight: 24px
  label:
    fontFamily: Instrument Sans
    fontSize: 12px
    fontWeight: '600'
    lineHeight: 16px
    letterSpacing: 0.1em
  caption:
    fontFamily: Instrument Sans
    fontSize: 12px
    fontWeight: '400'
    lineHeight: 16px
  mono-data:
    fontFamily: jetbrainsMono
    fontSize: 14px
    fontWeight: '400'
    lineHeight: 20px
rounded:
  sm: 0.5rem
  DEFAULT: 1rem
  md: 1.5rem
  lg: 2rem
  xl: 3rem
  full: 9999px
spacing:
  base: 4px
  xs: 4px
  sm: 8px
  md: 16px
  lg: 24px
  xl: 32px
  gutter: 16px
  margin-mobile: 16px
  margin-desktop: 32px
---

## Brand & Style
The design system is a rigorous exercise in reduction. It follows a strict "INK" philosophy—a monochromatic, high-contrast aesthetic that treats the interface like a digital broadsheet or a precision-engineered tool. It is built for a native Android environment but rejects standard Material Design flourishes in favor of an austere, minimalist layout.

The emotional response is one of focus, authority, and calm. By removing color, shadows, and ornamentation, the design system forces the user's attention toward content and structural hierarchy. The primary visual engine is "inversion"—using absolute black and white transitions to denote focus, action, or importance.

## Colors
This design system utilizes a strictly monochromatic palette. There are no semantic colors (success, warning, error) represented through hue; intent must be communicated through iconography, weight, or inversion.

- **Ground**: The base layer of the application.
- **Surface**: Used for cards, sheets, and persistent containers.
- **Raised**: Used for interactive elements like buttons and high-priority overlays (snackbars).
- **Hairline & Stroke**: Used for structural separation and input boundaries.
- **Inversion**: The primary accent method. High-priority actions or active states flip the palette from dark-on-black to dark-on-white.

## Typography
The typography relies on **Instrument Sans** for all variable-width roles and **JetBrains Mono** for all data-heavy or numeric contexts. 

- **Hierarchy**: Use weight (Regular to SemiBold) rather than size to denote importance where possible.
- **Labeling**: Labels are strictly uppercase with increased letter spacing to provide a technical, architectural feel.
- **Numbers**: Any financial data, timestamps, or technical metrics must use JetBrains Mono with tabular figures enabled to ensure vertical alignment in lists and tables.

## Layout & Spacing
The layout follows a strict 4px baseline grid. On Android, the standard 8dp rhythm is halved to 4dp to allow for tighter, more precise "ink-like" density.

- **Grid**: A 12-column fluid grid for tablet/desktop; 4-column for mobile.
- **Margins**: 16px lateral margins on mobile, increasing to 32px or higher on larger screens to maintain a narrow, readable "column of text" feel.
- **Vertical Rhythm**: Spacing between sections should be generous (24px or 32px) to compensate for the lack of color-based separation.

## Elevation & Depth
Depth is strictly flat. 
- **No Shadows**: Elevation is communicated solely through color steps (Ground → Surface → Raised). 
- **Layering**: A higher Z-index element (like a modal or snackbar) uses the `surface_raised` color (#1E1E1E) or an `inverted_surface` (#F5F5F5) to physically contrast against the base layers.
- **Borders**: Hairline (#262626) dividers are the only method for separating list items or logical sections.

## Shapes
The shape language is a "Pill" system. While the layout is rigid and rectangular, interactive elements use full rounding to distinguish them from static containers.

- **Interactive Elements**: Buttons, Input fields, and Chips always use the `rounded-xl` (Pill) setting.
- **Containers**: Cards and bottom sheets use `rounded-lg` (1rem) to soften the corners of the viewport.
- **Stroke**: Use 1px widths for `hairline` and 1.5px or 2px widths for `stroke` to maintain a refined, thin-line aesthetic.

## Components
- **Buttons**:
    - **Primary**: Inverted surface (#F5F5F5) with Ground text (#0C0C0C). Pill-shaped.
    - **Secondary**: Raised surface (#1E1E1E) with Primary text (#F5F5F5). 
    - **Tertiary**: No background, Primary text, 1px Hairline border.
- **Inputs**: Pill-shaped containers with a 1px `stroke` (#333333). Label typography floats above the input in the `label` style.
- **Chips**: Small pill-shaped containers. Unselected: Hairline border. Selected: Inverted (White background).
- **Icons**: 24dp bounding box, 1.5px stroke weight. Avoid filled icons unless indicating a "selected" state.
- **Lists**: Separated by 1px Hairline (#262626) borders. No chevrons for navigation; use typography weight to indicate drill-down priority.
- **Snackbars**: Use the `surface_raised` background with a `primary_text` label. If an "Undo" or action is present, it should be in all-caps `label` style.