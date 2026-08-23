# Stitch Prompt Pack — Todo App (all screens + widget)

Paste-ready prompts for **Google Stitch** covering every UI surface in requirements v3. No measurements anywhere — alignment is held instead by **relational rules**: one shared margin, straight edges, same baselines, single-line labels, and identical anatomies reused on every screen. Stitch still has nothing to assume; it just isn't told sizes in numbers.

---

## How to run this in Stitch

1. New project → toggle **App** (mobile). Use the highest **Pro/Experimental** model for final screens; Flash/Standard for drafts or Figma export.
2. **Every message you send = LAYOUT CONTRACT + one screen prompt.** The contract is what holds alignment, so it goes at the top of *every* generation, not just the first.
3. Add the **STYLE block** as well in Prompt 0, and again any time colors or typefaces drift.
4. One screen per message, one generation per screen — never ask for two frames in the same generation.
5. If a generated screen has a layout fault, don't regenerate — reply with the single correction stated as an exact relationship ("the 'Later' label must be one line, centered under the left circle, directly below the track").
6. After a batch of 3–4 screens, multi-select them (Shift+Click) and paste STYLE + CONTRACT once as a theme prompt to re-unify.
7. Export Figma (Standard mode) or screenshots as the visual spec; implementation is Jetpack Compose per requirements.md.

---

## STYLE block (paste in Prompt 0, and on any color/type drift)

```text
STYLE: "INK" — strict monochromatic dark system. No hue anywhere; every
color is a neutral grey. Tonal ladder: ground #0C0C0C, surface #161616,
raised #1E1E1E, hairline #262626, stroke #333333, disabled #5C5C5C,
secondary text #A3A3A3, primary text #F5F5F5, and a pure inverted surface
(#F5F5F5 with #0C0C0C text; secondary-on-light #4A4A4A).
INVERSION is the accent: the single most important element in any region
is inverted (white surface, black text) — the primary button, the selected
chip, the "up next" card, overdue time tags. Exactly one inverted element
per region.
Typography: Instrument Sans for all UI text, in only three weights —
regular, medium, semibold. JetBrains Mono for every time and number, with
tabular figures. Type roles, from largest to smallest: display, title,
heading, body, label (uppercase, letterspaced), caption. The same role is
the same size everywhere in the app.
State encoding: overdue = time inside a small inverted tag + semibold
title; completed = thin check + strikethrough + clearly faded; HIGH
priority = a thin solid white bar on the row's left edge + an outlined
"HIGH" chip; MEDIUM = the same bar in grey; LOW = no bar; recurring =
thin ↻ icon; queued offline = dashed border + cloud-off icon.
Mood: precise, austere, Braun-instrument minimalism. No gradients, no
glassmorphism, no shadows, no illustration, no emoji, no color.
```

## LAYOUT CONTRACT (paste at the top of EVERY prompt)

```text
LAYOUT CONTRACT — follow exactly; do not assume, add, or rearrange:
- One Android phone screen per generation, portrait. Render only the
  elements listed in the prompt, in the listed order — no extra icons,
  images, badges, illustrations, or decorations.
- Margins: one shared side margin, identical on left and right, used by
  every element on every screen. Content never touches the screen edge
  and never uses a different margin than its neighbors.
- Alignment: everything lives on a single vertical axis. An element is
  horizontally centered ONLY when the prompt marks it (centered);
  everything else is left-aligned to the shared margin. Never mix
  centered and left-aligned lines inside one block.
- Spacing: even rhythm — siblings within a group share the same gap, and
  the gap between groups is visibly larger than the gap within a group.
- Text: every label and caption is ONE line — never wrapped, hyphenated,
  or clipped. A label under an icon or circle is centered to that icon's
  center, directly below it, one line, and may be wider than the icon.
- Times: JetBrains Mono, tabular. When digits and AM/PM appear together
  they form ONE row on the SAME baseline: the meridiem is much smaller
  than the digits and sits immediately after them — never above, never
  floating, never on its own line.
- TODO ROW (default anatomy for every todo row): a fixed-width time rail
  on the left holding the mono time, left-aligned so all times in a list
  form one straight vertical edge; then the title (body size, primary
  text) with an optional one-line caption in secondary grey directly
  under it — all titles start at a second straight vertical edge; then
  flexible space; then an empty circular checkbox with a thin grey
  outline at the right margin. All rows are the same height, comfortably
  tall, with a thin hairline divider between rows running margin to
  margin.
- SECTION HEADER: one row — an uppercase letterspaced label in secondary
  grey at the left margin, and its mono count at the right margin, on the
  same line. Small gap to the first row beneath.
- BUTTONS: pill-shaped, full width between the margins, all the same
  comfortable height, label centered, semibold. Stacked buttons share one
  small equal gap.
- CHIPS: all the same height, pill-shaped, one-line label. Selected chip
  = inverted (white with black label); unselected = thin grey outline
  with secondary-grey label.
- BOTTOM SHEET: full width, rounded top corners, dark surface, a small
  centered drag handle at the top, one consistent inner padding, contents
  left-aligned unless marked (centered).
- BOTTOM NAV: a bar of four equal-width items, each a line icon over a
  small one-line label, both centered in their quarter. Active item:
  white icon and label with a small solid white dot just above the icon;
  inactive items dimmed grey.
- Icons: thin-stroke line icons, one consistent size unless stated.
  Avatars: grey circles with a single white initial. Status bar: minimal
  dark system bar unless the prompt says none.
```

---

## Prompt 0 — App context + Home screen

```text
Design a native Android todo app (dark theme). Core idea: todos are added
by typing one short natural-language message ("dsa 7pm daily") into a
chat-style input; the app schedules them with alarm-style reminders. It
also has recurring todos, history, shared "rooms", and a widget.

[PASTE STYLE BLOCK]
[PASTE LAYOUT CONTRACT]

SCREEN: HOME (Today). Background #0C0C0C. Top to bottom:

1. Status bar (minimal, dark).
2. Header row A: uppercase label "TODAY" at the left margin; "3 LEFT" in
   small mono secondary grey at the right margin — same line.
3. Header row B, just below: "Sat, Aug 23" in mono heading size, primary
   text, left; a cloud-sync line icon at the right margin, vertically
   centered to this row.
4. Scrollable list (render exactly these items, this order):
   a. SECTION HEADER "OVERDUE" / count "1".
   b. TODO ROW: the time rail shows "11:00 AM" inside a small inverted
      tag (white pill, black mono text); title "Reply to Sam" in
      semibold; caption "2h late".
   c. SECTION HEADER "TODAY" / count "4".
   d. UP NEXT CARD — the list's only inverted element: a full-width white
      card with softly rounded corners and a thin solid black bar filling
      its entire left inner edge. Inside, all left-aligned: tiny
      uppercase label "UP NEXT" in muted grey-on-white → "5:00 PM" on one
      line in large mono semibold black → "Project Meeting" in heading
      semibold black → a bottom row with an outlined black "HIGH" chip at
      the left and a black-outlined circular checkbox at the right.
   e. TODO ROW: rail "7:00 PM"; title "DSA"; caption = small ↻ icon +
      "Daily".
   f. TODO ROW: rail "9:00 PM"; title "Read"; no caption.
   g. TODO ROW (all-day): the rail shows the word "ALL DAY" in tiny caps
      secondary grey instead of a time; title "Pay rent"; no caption.
   h. QUEUED ROW: same row anatomy but wrapped in a dashed grey border
      with rounded corners, no divider, no checkbox; the rail holds a
      cloud-off line icon; title "gym 6am mon wed fri" in secondary grey;
      caption "Waiting for internet".
   i. SECTION HEADER "TOMORROW" / count "1".
   j. TODO ROW: rail "6:00 AM"; title "Gym"; caption = ↻ icon +
      "Mon/Wed/Fri".
5. SNACKBAR floating just above the input: a raised dark pill spanning
   the margins: "Added · DSA, today 7:00 PM" at its left, "Undo" in
   semibold white at its right.
6. INPUT BAR above the nav: a pill input spanning the margins on the dark
   surface tone with a thin grey stroke. Inside: a small "+" icon near
   its left edge; the one-line placeholder "Add a todo…  try: dsa 7pm
   daily" in dimmed grey; and, tucked at its right edge, a round inverted
   send button (white circle, black up-arrow) — the region's one inverted
   element.
7. BOTTOM NAV: Today (active) · History · Rooms · Settings.
```

## Prompt 1 — Manual add form (bottom sheet)

```text
[PASTE LAYOUT CONTRACT]

SCREEN: HOME dimmed by a plain black scrim, with a tall BOTTOM SHEET
open — MANUAL ADD FORM. Sheet contents, top to bottom, left-aligned:

1. Drag handle. Title "New todo" in heading semibold.
2. Text field with a thin grey stroke and rounded corners: small floating
   label "Title", value "Gym".
3. Uppercase label "Date", then one chip row: [Today] (inverted/selected)
   [Tomorrow] [Pick date…] with equal gaps.
4. Uppercase label "Time", then one row, vertically centered: "6:00 AM"
   in large mono at the left; an outlined chip "All-day" at the right.
5. Uppercase label "Repeat", then chips that may wrap onto a second row
   with equal gaps in both directions: [None] [Daily] [Weekdays] [Weekly]
   [Monthly] [Every N days] [Specific days] — "Specific days" inverted.
6. Day toggles: seven equal circles in one evenly spaced row, labeled
   S M T W T F S; M, W and F are filled white with black letters, the
   rest thin grey outlines with grey letters.
7. Uppercase label "Ends", then chips: [Never] (inverted) [On date]
   [After N times].
8. Uppercase label "Priority", then a segmented control spanning the
   margins with three equal segments LOW / MEDIUM / HIGH; the MEDIUM
   segment inverted.
9. BUTTON (inverted): "Save todo".
10. Caption "Works offline" in dimmed grey, one line, (centered).
```

## Prompt 2 — AI confirmation sheet

```text
[PASTE LAYOUT CONTRACT]

SCREEN: HOME dimmed by a black scrim; the chat input above the sheet
shows the sent message "meeting tomorrow evening". A compact BOTTOM
SHEET — AI CONFIRMATION. Contents, top to bottom, left-aligned:

1. Drag handle. Uppercase label "I UNDERSTOOD THIS AS".
2. Summary card on the raised tone with rounded corners: title "Meeting"
   in heading semibold → "Tomorrow · 6:00 PM" in mono secondary grey on
   the next line → one chip row: outlined [No repeat], outlined [Medium].
3. Info row, one line: a small right-arrow line icon, then "Moved to
   tomorrow — 5:00 PM today has already passed" in body medium, primary
   text.
4. Two buttons side by side, equal widths, one small gap: [Create]
   inverted, [Edit] thin grey outline.
```

## Prompt 3 — Fullscreen reminder (alarm screen)

```text
[PASTE LAYOUT CONTRACT]

SCREEN: FULLSCREEN TODO REMINDER — fires over the lockscreen. The app's
ONLY all-white screen: background #F5F5F5, everything on it black. No
status bar, no navigation. Every element on this screen is (centered) on
the vertical axis. Top to bottom:

1. Generous top space, then the uppercase letterspaced label "TODO DUE"
   in muted grey-on-white.
2. The time, one row, one shared baseline: digits "5:00" in mono as the
   single largest element on the screen, then "PM" in mono much smaller,
   immediately after the digits on the same baseline — never above them,
   never floating. No ring, no circle, no container around the time.
3. Title "Project Meeting" in title semibold black, staying on one or
   two centered lines.
4. Chip "HIGH": solid black with a white label.
5. Caption "Due now · Sat, Aug 23" in muted grey-on-white, one line.
6. Large flexible empty space.
7. SLIDE CONTROL near the bottom, comfortably above the screen edge:
   - A track: one wide pill spanning the margins, in a light grey a few
     steps darker than the background, tall enough for a thumb.
   - At its left end, just inside the track: a circle with a thin black
     outline, transparent fill, holding a black snooze-clock line icon.
   - At its right end, just inside the track: a solid black circle
     holding a white check icon.
   - At the exact center of the track: a solid black draggable puck, the
     same size as the end circles, holding a white bell icon.
   - Between the puck and each end circle: three small muted chevrons
     pointing outward (‹ ‹ ‹ toward the left, › › › toward the right),
     vertically centered on the track.
   - Directly below the track: the label "Later" centered under the LEFT
     circle's center, in muted grey; the label "Done" centered under the
     RIGHT circle's center, in semibold black. Each exactly one line.
   - Below the labels: the one-line caption "Slide right to finish ·
     left to snooze" in muted grey, (centered).

(Then use Create Variant for the drag state: the puck pulled most of the
way toward the right, the track to the puck's LEFT filled solid black,
the left circle and "Later" label clearly faded, and the caption replaced
by "Release to mark done".)
```

## Prompt 4 — Snooze options sheet

```text
[PASTE LAYOUT CONTRACT]

SCREEN: the all-white FULLSCREEN REMINDER (todo "DSA", due "7:00 PM",
same layout as before) dimmed by a black scrim, with a dark BOTTOM SHEET
open — SNOOZE OPTIONS, shown after the user slides the puck to "Later".
Contents, top to bottom:

1. Drag handle. Title "Remind me in" in heading semibold, left-aligned.
2. Four option rows of equal height with thin hairline dividers between
   them. Each row, vertically centered: the duration in body medium at
   the left; the resulting time in mono secondary grey at the right:
   - "15 minutes"   →  "7:15 PM"
   - "30 minutes"   →  "7:30 PM"   ← render this one row inverted (white
     background, both texts black) as the pressed state
   - "1 hour"       →  "8:00 PM"
   - "2 hours"      →  "9:00 PM"
```

## Prompt 5 — Conflict dialog

```text
[PASTE LAYOUT CONTRACT]

SCREEN: HOME dimmed by a black scrim with a centered DIALOG — TIME
CONFLICT. The dialog is a dark-surface card with rounded corners, its
own inner padding, narrower than the screen, contents left-aligned:

1. Title "Time conflict" in heading semibold. Subtitle "5:00 PM · today"
   in mono secondary grey on the next line.
2. Two mini rows with a hairline divider between them. Each row,
   vertically centered: the mono time "5:00 PM" in a fixed-width rail at
   the left so both times align; then the title in body medium ("Project
   Meeting" on the first row, "Gym" on the second); then, at the row's
   right, a small outlined chip — "existing" on the first, "new" on the
   second.
3. Three stacked buttons spanning the dialog's inner width, equal gaps:
   [Keep both] thin grey outline; [Move new task] inverted; [Cancel] as
   plain centered text in secondary grey.
4. One-line caption in dimmed grey: "Suggests the next free slot —
   5:30 PM".
```

## Prompt 6 — Disambiguation sheet

```text
[PASTE LAYOUT CONTRACT]

SCREEN: HOME dimmed by a scrim; the chat input above the sheet shows the
sent message "finished dsa". A small BOTTOM SHEET — DISAMBIGUATION.
Contents:

1. Drag handle. Title "Which one?" in heading semibold, left-aligned.
2. Two candidate rows using the TODO ROW anatomy, with a small chevron
   in place of the checkbox and a hairline divider between them:
   - Row 1: rail "7:00 PM"; title "DSA"; caption = ↻ icon + "Today".
   - Row 2: rail "7:00 PM" inside a small inverted tag (as on Home's
     overdue row); title "DSA"; caption "Yesterday · Overdue".
3. [Cancel] as plain centered text in secondary grey with a comfortable
   tap area.
```

## Prompt 7 — History screen

```text
[PASTE LAYOUT CONTRACT]

SCREEN: HISTORY. Background #0C0C0C. Top to bottom:

1. Status bar. Uppercase label "HISTORY" at the left margin.
2. A segmented control spanning the margins with two equal segments:
   "Completed" inverted (selected); "Missed" with, right after its
   label on the same line, a tiny inverted count tag "2".
3. List:
   a. Date header row: "SAT, AUG 23" uppercase letterspaced secondary
      grey at the left margin; "2" in small mono at the right margin.
   b. TODO ROW, clearly faded overall: rail "7:00 PM"; title "DSA" with
      a strikethrough; the checkbox replaced by a thin check icon.
   c. TODO ROW, faded: rail "5:00 PM"; title "Project Meeting",
      strikethrough; thin check icon.
   d. Date header row: "FRI, AUG 22" left, "3" right.
   e. Three more faded completed rows, same anatomy: "8:00 PM Leetcode",
      "6:00 AM Gym", "9:00 AM Standup".
4. BOTTOM NAV: Today · History (active) · Rooms · Settings.
```

## Prompt 8 — Rooms list

```text
[PASTE LAYOUT CONTRACT]

SCREEN: ROOMS. Background #0C0C0C. Top to bottom:

1. Status bar. Header row: uppercase label "ROOMS" at the left margin; a
   "+" line icon at the right margin, vertically centered.
2. Room card: full width between the margins, dark surface, rounded
   corners, thin hairline outline, its own inner padding. Inside,
   left-aligned: name "Project Room" in heading semibold → an avatar row
   of three overlapping initial-avatars T, R, A → a one-line meta:
   "3 open" in secondary grey, then " · ", then "1 due today" in
   semibold primary text. A small chevron vertically centered at the
   card's right padding edge.
3. Second card, same anatomy: "Study Group", two avatars (S, K), meta
   "2 open" entirely in secondary grey, chevron.
4. Empty-slot hint: a full-width dashed-border card with rounded corners
   containing the single (centered) line "Create a room to share todos"
   in dimmed grey.
5. BOTTOM NAV: Today · History · Rooms (active) · Settings.
```

## Prompt 9 — Room detail (Tasks tab)

```text
[PASTE LAYOUT CONTRACT]

SCREEN: ROOM DETAIL for "Project Room". Background #0C0C0C. Top to
bottom:

1. Status bar. App-bar row: a back-arrow at the left margin; an overflow
   (⋮) icon at the right margin; both vertically centered.
2. Name "Project Room" in title semibold, left-aligned.
3. Member row: three initial-avatars T, R, A in a row with equal gaps,
   left-aligned; directly under the FIRST avatar, a one-line micro-label
   "ADMIN" in tiny uppercase letterspaced secondary grey, centered to
   that avatar's center.
4. Tabs row, left-aligned: "Tasks" in body semibold primary text with a
   thin white underline exactly the width of the word → a gap →
   "Activity" in body dimmed grey. A hairline runs under the full row,
   margin to margin.
5. Task list, TODO ROW anatomy with one addition — the caption line is a
   small initial-avatar, then the assignee name in caption grey, then
   any extra caption text:
   a. Rail "5:00 PM"; title "Build API"; caption avatar T + "Tejas".
   b. Rail "7:00 PM"; title "Build UI"; caption avatar R + "Rahul · "
      then "due soon" in caption medium primary text.
   c. Rail "TMRW" (tiny caps secondary grey in the rail); title
      "Testing"; caption avatar A + "Amit".
6. INPUT BAR pinned at the bottom: identical anatomy to Home's input,
   placeholder "Add a shared todo…", with the round inverted send
   circle. No bottom nav on this screen.
```

## Prompt 10 — Room detail (Activity tab)

```text
[PASTE LAYOUT CONTRACT]

SCREEN: ROOM DETAIL for "Project Room", identical header, name, member
row and tabs to the Tasks screen — but now "Activity" carries the white
underline and "Tasks" is dimmed grey. Below the tabs hairline:

1. Timeline list. Each entry is one row of equal height: a fixed-width
   mono timestamp rail at the left so all timestamps form one straight
   edge → a small initial-avatar → the event text in body primary, one
   line, vertically centered. A continuous thin hairline vertical line
   runs behind the avatar centers, connecting all entries top to bottom:
   a. "10:32 AM" · avatar R · "Rahul created 'Build UI'"
   b. "10:45 AM" · avatar R · "Rahul assigned it to Tejas"
   c. "11:20 AM" · avatar T · "Tejas changed the deadline to 6:00 PM"
   d. "5:48 PM"  · a thin check icon in place of the avatar · "Tejas
      completed 'Build UI'" — this row clearly faded.
2. No input bar on this tab. No bottom nav.
```

## Prompt 11 — Shared task detail (comments)

```text
[PASTE LAYOUT CONTRACT]

SCREEN: ROOM DETAIL dimmed by a scrim with a tall BOTTOM SHEET — SHARED
TASK DETAIL. Contents, top to bottom, left-aligned:

1. Drag handle. Header row: title "Build UI" in heading semibold at the
   left; an empty circular checkbox at the right; same line, vertically
   centered.
2. Four detail rows of equal height with hairline dividers. Each row:
   the label in small secondary grey at the left; the value at the
   right, body medium primary:
   - "Assignee" → a small avatar R + "Rahul"
   - "Due" → "Today · 7:00 PM" in mono
   - "Repeat" → "None"
   - "Priority" → "Medium"
3. Uppercase label "COMMENTS".
4. Two comment blocks with an equal gap between them. Block anatomy: a
   small avatar at the left; to its right, one line holding the name in
   caption semibold primary and the time in tiny mono dimmed grey; the
   comment text in body secondary grey on the next line, allowed to wrap
   to a second line:
   - Tejas · "10:50 AM" · "Keep it strictly monochrome like the
     mockups."
   - Rahul · "11:02 AM" · "On it — pushing a draft tonight."
5. BUTTON (inverted): "Mark complete".
6. Comment input: a pill with a thin grey stroke, placeholder "Add a
   comment…" in dimmed grey, and a small round inverted send circle
   tucked at its right edge.
```

## Prompt 12 — Create room / invite sheet

```text
[PASTE LAYOUT CONTRACT]

SCREEN: ROOMS dimmed by a scrim with a BOTTOM SHEET — CREATE ROOM &
INVITE. Contents, top to bottom, left-aligned:

1. Drag handle. Title "New room" in heading semibold.
2. Text field with a thin grey stroke and rounded corners: floating
   label "Room name", value "Project Room".
3. Uppercase label "INVITE", then one row, vertically centered: the room
   code "TDQ-482" in large letterspaced mono primary text at the left; a
   copy line icon at the right margin.
4. BUTTON (thin grey outline): "Share invite link", with a small share
   icon just before the label.
5. Uppercase label "MEMBERS", then three rows of equal height with
   hairline dividers: a small avatar, then the name in body primary.
   Row 1 "Tejas" followed by " — Admin (you)" in caption secondary grey,
   with no trailing icon. Rows 2 "Rahul" and 3 "Amit" each end with a
   small minus (–) line icon at the right margin.
6. BUTTON (inverted): "Create room".
```

## Prompt 13 — Settings

```text
[PASTE LAYOUT CONTRACT]

SCREEN: SETTINGS. Background #0C0C0C. Top to bottom:

1. Status bar. Uppercase label "SETTINGS" at the left margin.
2. Section label "ACCOUNT" in uppercase secondary grey. A row: a larger
   initial-avatar "T" → two stacked lines, "Tejas" in body medium and
   the email "tejas@gmail.com" in caption grey → flexible space → a
   small chevron. Under it, a plain left-aligned text button "Sign out"
   in secondary grey.
3. Section label "REMINDERS". Rows of equal height with hairline
   dividers:
   a. "Quiet reminders" in body primary at the left with a toggle at the
      right, OFF (grey track, dimmer grey thumb); a one-line caption
      under the label in dimmed grey: "Won't override silent or Do Not
      Disturb".
   b. "Morning default" left; "9:00 AM" in mono secondary grey right,
      then a chevron.
   c. "Evening default" left; "6:00 PM" right, chevron.
   d. "All-day reminder" left; "9:00 AM" right, chevron.
4. Section label "PERMISSIONS". A row: "Reminder permissions" in body
   primary with a small solid white dot just after the text; a one-line
   caption under it in dimmed grey: "Battery optimization not exempted";
   a chevron at the right.
5. Section label "ABOUT". A row: "Version 1.0" in body secondary grey.
6. BOTTOM NAV: Today · History · Rooms · Settings (active).
```

## Prompt 14 — Sign-in screen

```text
[PASTE LAYOUT CONTRACT]

SCREEN: SIGN-IN. Background #0C0C0C. No bottom nav. Every element
(centered). Top to bottom:

1. Flexible top space, roughly the top quarter of the screen.
2. App mark: a large thin white ring containing only two thin white line
   clock hands set to seven o'clock (hour hand toward lower-left, minute
   hand straight up). No fill, nothing else inside.
3. Headline "Type it. It reminds you." in title semibold primary, one
   line.
4. Sub-line "dsa 7pm daily → done." in mono body secondary grey, one
   line, just below the headline.
5. Flexible space.
6. Google's standard light "Continue with Google" button, spanning the
   margins (Google branding — the one element allowed its own colors).
7. Plain text button "Continue without an account" in secondary grey,
   with a comfortable tap area.
8. Caption in dimmed grey, at most two (centered) lines: "An account is
   only needed for sync and shared rooms. Everything else works
   offline."
9. Comfortable bottom padding.
```

## Prompt 15 — Permissions onboarding (pager)

```text
[PASTE LAYOUT CONTRACT]

SCREEN: ONBOARDING PERMISSIONS, the last step of four. Background
#0C0C0C. No nav. Every element (centered). Top to bottom:

1. Progress dots near the top: four small circles in an evenly spaced
   row — the first three thin grey outlines, the fourth solid white.
2. Flexible space.
3. Icon: a large battery outline drawn in thin white line style with a
   small bell inside it. No fill, no extra marks.
4. Title "Keep reminders alive" in title semibold primary, one line.
5. Body in secondary grey, (centered), at most three lines, noticeably
   narrower than the full margin width: "Some phones stop background
   alarms to save battery. Allow the app to run unrestricted so
   reminders always fire — especially on Xiaomi, Oppo and Vivo."
6. Flexible space.
7. BUTTON (inverted): "Open battery settings".
8. Plain text button "Later" in secondary grey.
9. One-line step caption near the bottom in tiny uppercase letterspaced
   dimmed grey: "1 NOTIFICATIONS · 2 EXACT ALARMS · 3 FULL-SCREEN ·
   4 BATTERY".

(For the earlier steps, use Create Variant and change only: the active
dot, the icon, the title, and the body text.)
```

## Prompt 16 — Home-screen widget

```text
[PASTE LAYOUT CONTRACT]

SCREEN: a phone home screen whose wallpaper is a plain flat dark grey —
nothing on it except the app's ANDROID WIDGET, centered vertically and
horizontally. The widget is a wide rectangle (the standard wide, short
widget slot), on the dark surface tone with generously rounded corners,
a thin hairline outline, and one consistent inner padding. Inside, top
to bottom:

1. Header row: "Today" in body semibold primary at the left; "3 left" in
   small mono secondary grey at the right. A thin hairline rule under
   it, spanning the widget's inner width.
2. Three compact rows of equal height, hairline dividers between them,
   each with a fixed-width mono time rail so the times form one straight
   edge, then the title on one line:
   - "5:00 PM  Project Meeting" — this row's time and title in primary
     white semibold (the widget's one emphasized row)
   - "7:00 PM  DSA" — time and title in secondary grey
   - "9:00 PM  Read" — time and title in secondary grey
3. Footer row: "+ Add todo" in primary white medium, left-aligned.

Render nothing else — no app icons, no dock, no clock on the wallpaper.
```

---

## UX review checklist (after export)

1. **One inverted element per region** — if two compete in white, demote one.
2. Hierarchy survives a squint: the most important thing reads first.
3. Everything tappable is comfortably thumb-sized; primary actions sit in thumb reach.
4. All readable text is clearly legible against its background; dimmed grey is captions/disabled only.
5. All states exist: pressed, focus, disabled, selected, empty, error, offline/queued.
6. Overdue / priority / completed / recurring each distinguishable with color vision removed.
7. **Alignment audit:** time rails form one straight vertical edge down every list; titles form a second straight edge; every label is one line; AM/PM sits on the digit baseline; labels under circles are centered to the circle's center.
8. Copy is active and consistent — "Done" everywhere, never "OK"/"Submit".
9. Empty states name the next action, never just an icon.
10. Motion minimal (drag feedback only) and reduced-motion respected.

## After generation

- Multi-select all screens → paste STYLE + CONTRACT once as a theme prompt to lock consistency.
- Screens generated from earlier editions: multi-select and paste both blocks — Stitch restyles in place.
- Fixing a fault: state the correction as an exact relationship on that one screen; don't regenerate the whole thing.
- Export Figma (Standard mode) or screenshots as the visual spec for the Compose build (requirements.md §27).
