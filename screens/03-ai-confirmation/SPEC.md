# Screen 03 — AI Confirmation Sheet (spec, no PNG)

No Stitch render exists for this screen. Build it from this spec — it uses
the same INK system and sheet anatomy as every other bottom sheet in
screens/ (match 02-manual-add-form for sheet chrome and spacing).

Behavior: requirements.md §5 (ambiguous-input confirmation) and §6
(past-time notice). Shown over Home when the AI parse of a typed todo has
`needsConfirmation: true`.

Layout — Home dimmed by a plain dark scrim; the chat input above the sheet
shows the sent message ("meeting tomorrow evening"). A compact bottom
sheet, contents top to bottom, left-aligned:

1. Drag handle. Uppercase letterspaced label "I UNDERSTOOD THIS AS" in
   secondary grey.
2. Summary card on the raised tone with rounded corners:
   - title (the parsed todo title, e.g. "Meeting") in heading semibold
   - next line: date · time in mono secondary grey ("Tomorrow · 6:00 PM")
   - one chip row: outlined chips for recurrence and priority
     ("No repeat", "Medium")
3. Info row (only when the past-time rule moved the todo, §6): a small
   right-arrow line icon + one line in body medium primary text:
   "Moved to tomorrow — 5:00 PM today has already passed".
4. Two buttons side by side, equal widths: [Create] inverted (white,
   black label — the sheet's one inverted element), [Edit] thin grey
   outline. [Create] saves the todo as shown; [Edit] opens the manual
   form (screen 02) prefilled with the parsed values.
