# UI/UX audit — INK screens

Scope: the 19 rendered screens in `screens/` (`code.html` + `screen.png`). 03 and 08 are SPEC.md only and were not changed.
Method: the Impeccable audit/polish/layout passes and the UI/UX Pro Max pre-delivery checklist (accessibility, touch, layout, type, consistency). Every screen was rendered headless at 390×844 and 360×780 and compared side by side. The theme was kept as is: the same INK monochrome ladder, Instrument Sans + JetBrains Mono, and inversion as the only accent.

## Health score (Impeccable rubric, 0–4 per dimension)

| Dimension | Before | After | Key finding |
|---|---|---|---|
| Accessibility | 1 | 3 | 15/19 screens had zero accessible names. Checkboxes were 24px non-interactive `div`s. |
| Performance | 2 | 3 | Each screen loaded its own font sets. A `backdrop-blur` scrim (also banned by the STYLE block) is removed. |
| Theming | 0 | 4 | Each screen inlined a 35–40-colour Material palette (#141313, #e5e2e1, #c4c7c8…) instead of the INK ladder. |
| Responsive | 1 | 3 | Content was cut off at 390×844 on 02, 06, 13, 16 and 19. 360px overflow is now clean on all screens. |
| Implementation integrity | 1 | 4 | Four bottom-nav variants, four onboarding templates, three different "white" primary buttons. |
| **Total** | **5/20 Critical** | **17/20 Good** | |

## Systemic causes (fixed at the root)

1. **No shared token layer.** Every Stitch export carried its own Material 3 palette and type scale. This produced grey text on grey text, inverted surfaces in three different whites, and 16px gutters instead of the 24dp in BUILD-SPEC §2.
   → `screens/_shared/ink.css` and `ink-tailwind.js` now hold the BUILD-SPEC §2 values once. Every screen loads them, and no screen restates colours or sizes.
2. **No shared anatomies.** The todo row, section header, bottom nav, sheet, button, chip, time and checkbox were rebuilt ad hoc on every screen, so the alignment drifted.
   → Each one is now a single class in `ink.css` that follows the LAYOUT CONTRACT in `design/stitch-prompts.md`.
3. **Arbitrary sizes.** Home alone had 26 one-off `[Npx]` values. Label text ranged from 9 to 12px across screens.
   → One type role is now one size everywhere.

## Findings by severity (all fixed)

**P1 — blocking or WCAG AA**
- Content was clipped at 390×844:
  - 02: "Works offline" was cut off.
  - 06: the 4th snooze option was cut off.
  - 13: the comment composer was cut off.
  - 16: the footer caption was cut off.
  - 19: the step caption was cut off.
- 14: the "Create room" label was white on light grey (≈1.3:1). Override 9 is applied.
- 17: the title and body rendered in a serif fallback. Override 4 is applied.
- Icon-only controls had no names (back, overflow, add, send, copy, remove, check). Toggles had no state (`aria-pressed`, `aria-checked`, `role="switch"`, `aria-current`).
- Touch targets were as small as 24px.
  - Checkboxes, icon buttons and slide-control ends now have 48px targets, with the visual mark optically on the margin.
  - Chips, segments, day toggles and the switch keep their pinned visual size and gain an invisible 48px hit area.

**P2 — alignment and consistency**
- Up Next card: the black left bar sat on the card's outer edge, so it merged with the dark ground and showed as "slivers" at the rounded corners. The bar is now inset inside the white card (override 1).
- Bottom nav: one implementation now serves 01, 09, 10 and 15. It has four equal quarters, sentence-case labels and a dot above the active item. 15 used uppercase labels and a filled icon; 02 used a pill highlight.
- Times: the meridiem is now always on the digits' baseline at 0.68em. Before, it sat at random sizes (9–14px) and sometimes floated.
- Settings dividers were inset 12px from the margin, and the values didn't share a right edge.
- 09: the Missed badge is inverted (override 8). 11: ADMIN is centered under the first avatar (override 7). 12: the activity connector stops at the last entry (override 6), and the status bar that only 12 had is now on every non-reminder screen.
- 05: the progress fill runs from the track's left end to the puck, and the snooze side is faded (override 3).
- 19: the phone-with-alarm icon replaces the reused alarm clock (override 5).
- Onboarding 17–20: these are now one template. The pager, icon, title, measure (32ch), button stack and step caption sit at identical positions.
- 01: the queued row title was struck through, but the spec says secondary grey only. The snackbar action now uses label style.

**P3 — polish**
- Focus-visible rings, selection colour, caret, `prefers-reduced-motion`, and press feedback (opacity/background, with no layout-shifting `scale`).

## Known, intentional exceptions

- **Disabled grey:** #5C5C5C on #0C0C0C is about 2.9:1, just under the 3:1 non-text minimum. It is pinned by BUILD-SPEC §2 for the checkbox stroke and is kept. Raising it to #6B6B6B would pass, but that is the spec owner's call.
- **Settings at 360×780:** it scrolls about 30px under the nav. It fits at 390×844.
- **12, "Tejas changed the deadline to 6:00 PM":** this wraps to two lines rather than being truncated.
- **Tailwind:** the screens still load the Tailwind CDN for layout utilities. They are references for the Compose build, not production code.

## For the Compose implementation

Map `ink.css` one to one:

| `ink.css` | Compose |
|---|---|
| `:root` tokens | `InkColors` / `InkType` / `InkDimens` |
| `.todo-row` | `TodoRow` |
| `.section-head` | `SectionHeader` |
| `.bottom-nav` | `InkBottomNav` |
| `.sheet` | `ModalBottomSheet` with a 24dp top radius |
| `.check` | `Modifier.minimumInteractiveComponentSize()` on a 24dp circle |

Use `Modifier.semantics` for every name and state listed above.
