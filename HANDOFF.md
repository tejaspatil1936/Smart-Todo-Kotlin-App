# INK Todo — Build Handoff

Everything needed to build the app is in this folder.

- **requirements.md** — the product spec, v3. Single build phase, no MVP cut. This document is the source of truth for all behavior.
- **BUILD-SPEC.md** — the engineering decisions: schemas, API contracts, the recurrence algorithm, sync protocol, design tokens, RLS policies, per-step definitions of done. Nothing may be invented that this file already pins.
- **screens/** — the visual spec (INK monochrome design system). 19 screens have `screen.png` (visual truth) + `code.html` (Stitch's HTML/CSS — a styling reference only, NOT production code, NOT the implementation). 2 screens (03, 08) ship as written `SPEC.md` files instead of renders — build them from the spec; they reuse anatomies visible in the other screens.
- **CLOUD-SETUP.md**, **.devcontainer/**, **.github/workflows/** — build everything in GitHub Codespaces + Actions when no capable laptop is available; APKs install to the phone over a forwarded port or Tailscale adb.
- **screens/_shared/** — `ink.css` + `ink-tailwind.js`: the single INK token and component layer every `code.html` loads (BUILD-SPEC §2 values, LAYOUT CONTRACT anatomies). Map it 1:1 to the Compose theme. The UI audit that produced it is `design/UI-AUDIT.md`; every `screen.png` was re-rendered from the fixed `code.html`, so the two now agree and already include the Spec overrides below.
- **design/** — `DESIGN.md` (Stitch's generated token sheet) and `stitch-prompts.md` (the design-system prompt pack; its STYLE block and LAYOUT CONTRACT are the authoritative statement of the design rules). Where DESIGN.md and the STYLE block disagree, the STYLE block wins.

**Precedence: requirements.md > BUILD-SPEC.md > "Spec overrides" below > screen.png > code.html.**

## Screen index

| # | Screen | Requirements |
|---|--------|--------------|
| 01 | Home (Today) — sections, Up-Next card, queued row, chat input, nav | §2, §5, §9, §23, §27 |
| 02 | Manual add form (bottom sheet) | §2, §23 |
| 03 | AI confirmation sheet — **SPEC.md, no PNG** | §5, §6 |
| 04 | Fullscreen reminder (all-white alarm, slide control) | §10, §11 |
| 05 | Reminder drag state | §11 |
| 06 | Snooze options sheet | §12 |
| 07 | Time-conflict dialog | §17 |
| 08 | Disambiguation sheet — **SPEC.md, no PNG** | §15 |
| 09 | History (Completed / Missed) | §9, §27 |
| 10 | Rooms list | §20 |
| 11 | Room detail — Tasks tab | §20 |
| 12 | Room detail — Activity tab | §21 |
| 13 | Shared task detail (comments) | §20, §21 |
| 14 | Create room / invite sheet | §20 |
| 15 | Settings | §4, §10, §19, §27 |
| 16 | Sign-in | §19 |
| 17–20 | Permissions onboarding, steps 1–4 | §26 |
| 21 | Home-screen widget | §13 |

## Spec overrides — where the pixels are wrong, implement this instead

1. **01 Home:** the Up-Next card carries a thin solid black bar filling its entire left inner edge (the HIGH-priority marker). The small sliver shapes peeking out behind the card's left edge in the PNG are render artifacts — do not implement them.
2. **02 Form:** the caption under "Save todo" reads **"Works offline"** (the PNG shows a wrong caption).
3. **05 Drag state:** in the real interaction the track fills solid black from its left end to the puck as the puck is dragged right (progress fill), and the snooze side fades. The PNG shows the end position without the fill.
4. **17 Onboarding step 1:** the title uses **Instrument Sans** like every other title — the serif in the PNG is a font-loading artifact from export.
5. **19 Onboarding step 3:** use a phone-with-alarm line icon; the PNG reuses step 2's alarm-clock icon.
6. **12 Activity:** the vertical connector line stops at the last entry.
7. **11 Room detail:** the "ADMIN" micro-label centers under the first avatar.
8. **09 History:** the Missed count badge is inverted (white pill, dark text).
9. **14 Create room:** the button label is dark at full contrast on the white fill.
10. **Consistency:** priority chips are uppercase ("HIGH") on every screen; bottom-nav labels are sentence case on every screen; every primary (inverted) button uses the same pure white fill.

## Design system, in one paragraph

Strict monochrome ("INK"): no hue anywhere. Grey ladder — ground `#0C0C0C`, surface `#161616`, raised `#1E1E1E`, hairline `#262626`, stroke `#333333`, disabled `#5C5C5C`, secondary text `#A3A3A3`, primary text `#F5F5F5`, inverted surface `#F5F5F5`-with-`#0C0C0C`. **Inversion is the accent**: exactly one inverted element per region (primary button, selected chip, Up-Next card, overdue time tag) — and the fullscreen reminder inverts the whole screen. Two typefaces only: Instrument Sans (UI) and JetBrains Mono (every time and number, tabular, meridiem smaller on the same baseline). State encoding without color: overdue = inverted time tag + semibold; completed = thin check + strikethrough + faded; priority = thin left-edge bar (white/grey/none) + chip; recurring = ↻; queued offline = dashed border + cloud-off. Full rules: `design/stitch-prompts.md` (STYLE block + LAYOUT CONTRACT).

## Build order (requirements §29 — one step at a time)

1. **Local core** — Kotlin + Compose project (min SDK 26), Room schema, todo service, recurrence engine (rolling 30-day materialization), states/lifecycle, manual add form, Home + History.
2. **Reminders** — exact alarms, fullscreen reminder + slide control, snooze, permission/battery onboarding, boot rescheduling.
3. **Supabase setup** — Supabase project, Postgres schema + Row Level Security policies, Groq-proxy Edge Function with per-user rate limiting (the API key lives only in function secrets).
4. **NL pipeline** — chat input → proxy → validation → intents (create/edit/complete/delete), confirmation + disambiguation sheets, offline outbox queue.
5. **Widget** — Glance widget with all refresh triggers.
6. **Accounts + sync** — Google Sign-In via Supabase Auth, hand-written Room↔Supabase sync layer (supabase-kt), local↔cloud merge, last-write-wins.
7. **Collaboration** — rooms + RLS roles, shared todos, comments, Realtime live updates, trigger-driven activity history, webhook → Edge Function → FCM.
8. **Hardening** — conflict detection, missed-alarm recovery, OEM battery-killer testing, end-to-end pass of every requirements section.

## Kickoff prompt (paste into Claude Code from this folder)

```
Read requirements.md fully, then BUILD-SPEC.md, then HANDOFF.md. Build this app exactly per
requirements v3 — the whole spec, single phase, in the §29 build order.
screens/ is the visual spec: screen.png is visual truth, code.html is a
styling reference only, and HANDOFF.md's "Spec overrides" beat the pixels.
Screens 03 and 08 have written SPEC.md files instead of renders.

Start with §29 step 1 (local core): create the Android project (Kotlin,
Jetpack Compose, Room, min SDK 26), then implement the data model,
recurrence engine with the rolling 30-day window, todo states/lifecycle,
the manual add form, and the Home and History screens matching
screens/01, 02, and 09.

Work one §29 step at a time, meeting BUILD-SPEC.md §15's definition of
done for that step. If anything is not pinned by these documents, ask me
instead of assuming. After each step, stop and give me: what you built,
how to run it, and exactly what to verify on a device before we continue.
```
