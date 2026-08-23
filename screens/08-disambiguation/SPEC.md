# Screen 08 — Disambiguation Sheet (spec, no PNG)

No Stitch render exists for this screen. Build it from this spec — same
INK system and sheet anatomy as the other bottom sheets in screens/.

Behavior: requirements.md §15 matching rules (shared by edit, complete,
and delete). Shown when a typed command ("finished dsa", "move meeting to
8pm", "delete gym") matches more than one candidate todo.

Layout — Home dimmed by a plain dark scrim; the chat input above the sheet
shows the sent message ("finished dsa"). A small bottom sheet:

1. Drag handle. Title "Which one?" in heading semibold, left-aligned.
2. Two or more candidate rows using the standard todo-row anatomy
   (fixed-width mono time rail → title → caption), with a small chevron
   in place of the checkbox and a hairline divider between rows:
   - e.g. rail "7:00 PM"; title "DSA"; caption = ↻ icon + "Today"
   - e.g. rail "7:00 PM" inside a small inverted tag (white pill, black
     mono text — the overdue treatment from Home); title "DSA"; caption
     "Yesterday · Overdue"
3. [Cancel] as plain centered text in secondary grey with a comfortable
   tap area.

Tapping a row applies the pending command (complete / edit / delete) to
that todo. Delete commands still show their confirmation after selection
(requirements §16).
