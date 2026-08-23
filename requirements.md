# Todo App — Requirements (v3)

The entire document is a **single build phase**: every feature below ships together. Nothing is staged into an MVP or deferred to a later version. Decisions made where judgment was delegated are written as normal requirements, not options.

---

## 1. Platform & Stack

* Native Android app: **Kotlin + Jetpack Compose**. Min SDK 26 (Android 8.0), target latest stable.
* Local database: **Room**. Scheduling: **AlarmManager (exact alarms) + WorkManager**. Widget: **Glance**.
* Backend: **Supabase** (managed Postgres + Auth + Edge Functions + Realtime) — no self-hosted server. Responsibilities in §22. App-side client: **supabase-kt**.
* Push notifications for collaboration: **Firebase Cloud Messaging (FCM)**.
* AI: **Groq API**, called only from a Supabase Edge Function — never directly from the app (§22).
* Android only. No iOS or web.

## 2. Todo Creation

* The user should be able to add a todo within **5 seconds** using a short chat-like input (the 5 seconds includes the AI round trip; server parse target ≤ 2 s).
* The user can enter raw natural-language text such as:

  * `chat 5pm project meet`
  * `dsa 7pm daily`
  * `gym 6am monday wednesday friday`
  * `team meeting 10am every monday`
  * `pay rent 9am monthly`
  * `leetcode every weekday 8pm`
  * `revision every 2 days`
  * `DSA 7pm daily for 30 days`
* The application should automatically understand the input and create the todo.
* Every auto-created todo shows a short **Undo / Edit** snackbar so the fast path is safe.
* A **manual add form** (title, date, time, recurrence, priority pickers) is always available as an alternative — and is the guaranteed path when offline (§23).

## 3. AI Parsing

* The application uses the **Groq API** (fast Llama-class model; final model chosen at implementation) via the backend proxy.
* The AI extracts:

  * Intent: `create`, `edit`, `complete`, or `delete`
  * Todo title
  * Date
  * Time
  * Recurrence
  * Recurrence end condition
  * Priority when specified
* The AI returns structured JSON only (§25).
* The AI never modifies the database or scheduler directly.
* All AI output passes through a validation layer (type checks, range checks, known-enum checks, date sanity) before any action is taken.

## 4. Time & Date Rules

```text
5       → 5 PM
5pm     → 5 PM
5am     → 5 AM
17:00   → 5 PM
5:30    → 5:30 PM
12      → 12 PM (noon)
```

* A time without AM/PM defaults to **PM** (applies to bare numbers 1–11 and to h:mm forms).
* Bare `12` means **noon**. Midnight must be explicit (`12am`).
* Word defaults:

```text
morning   → 9:00 AM
noon      → 12:00 PM
afternoon → 3:00 PM
evening   → 6:00 PM
night / tonight → 9:00 PM
```

* **No time given** → the todo is an **all-day todo** for that date. All-day todos get one standard notification at 9:00 AM (no fullscreen alarm).
* **No date and no time** (`buy milk`) → all-day todo for today.

## 5. Ambiguous Input Confirmation

* If the AI is confident, the todo is created immediately (the PM default and word defaults count as confident — no confirmation for `dsa 7` or `meeting tomorrow evening`... unless other parts are unclear).
* The AI sets `needsConfirmation: true` when input is genuinely uncertain: vague timing words with no default ("later", "soon"), conflicting information, or a low-confidence title. The app then shows:

```text
I understood this as:

Meeting
Tomorrow at 6:00 PM

[ Create ] [ Edit ]
```

* If critical information is missing and cannot be defaulted, the application asks the user instead of guessing.

## 6. Past-Time Handling

* **One-off todo, today's time already passed** (`chat 5pm` entered at 6 PM) → schedule for **tomorrow** at that time, and show the confirmation card with "(moved to tomorrow)" so the user can override.
* **One-off todo with an explicit past date** (`meeting aug 20` on Aug 23) → ask the user; never silently schedule in the past.
* **Recurring todo** → the first occurrence is simply the next valid occurrence; no prompt. (`dsa 7pm daily` entered at 8 PM starts tomorrow.)

## 7. Recurrence Types

### Daily
```text
dsa 7pm daily
```

### Specific Days
```text
gym 6am monday wednesday friday
```

### Weekly
```text
team meeting 10am every monday
```

### Monthly
```text
pay rent 9am monthly
```
* Monthly on day 29–31 **clamps to the last day** of shorter months (rent on the 31st → Feb 28/29), then returns to the original day.

### Weekdays
```text
leetcode every weekday 8pm
```

### Every N Days
```text
revision every 2 days
```
* Anchored to the first occurrence date (the stated date, else creation date).

### End Conditions
```text
DSA 7pm daily for 30 days     → end date = start + 30 calendar days
dsa 7pm daily until sep 15    → explicit end date (inclusive)
dsa 7pm daily 10 times        → fixed occurrence count
```
* No end condition → the series runs indefinitely.

## 8. Recurrence Engine

* Recurring todos create **individual occurrences**; completing one never affects others:

```text
Aug 23 → DSA → Completed
Aug 24 → DSA → Pending
Aug 25 → DSA → Pending
```

* Occurrences are materialized on a **rolling 30-day window**, regenerated daily by a background worker and on app open. The widget, conflict detection, and reminders operate on materialized occurrences.

## 9. Todo States & Lifecycle

* States: **Pending → Completed** or **Missed**. A pending todo past its due time (same day) displays as **Overdue**.
* **Recurring occurrence** not completed by midnight → automatically marked **Missed** (keeps the list clean; visible in History).
* **One-off todo** past its due time → stays **Overdue** at the top of the list until completed, rescheduled, or deleted.
* Completed and Missed todos are visible in the History screen.

## 10. Notifications

When a todo becomes due:

* Show a notification, play a sound, and vibrate.
* Display a fullscreen reminder UI.
* Sound and vibration continue for a maximum of **1 minute**, then stop.
* The notification remains visible until the user takes an action.
* Reminders play on the **alarm audio stream** and ring through silent mode and Do Not Disturb by default (alarm-clock behavior). A Settings toggle — **"Quiet reminders"** — downgrades them to normal notification behavior.
* **Multiple todos due the same minute** → one fullscreen reminder listing all of them, one alarm.
* **Missed while the device was off**: if less than 60 minutes late at boot/unlock, fire immediately as a standard notification (short sound, no fullscreen); if later, mark per §9 with no sound.
* Alarms are rescheduled on reboot (`BOOT_COMPLETED`).

## 11. Fullscreen Todo Reminder

```text
┌─────────────────────────────┐
│                             │
│        TODO DUE             │
│                             │
│        5:00 PM              │
│     Project Meeting         │
│                             │
│                             │
│  (Zz)···⟨ ● ⟩···(✓)         │
│  Remind later     Done      │
│                             │
└─────────────────────────────┘
```

* The reminder uses a **phone-call-style slide control** instead of buttons: a horizontal track with a central draggable puck. Because the screen fires over the lockscreen, sliding prevents accidental pocket-taps from completing or snoozing a todo.
* **Slide right → Done**: marks the occurrence **completed**.
* **Slide left → Remind Me Later**: opens snooze options (§12).
* Both end targets are also directly tappable, as the accessibility fallback (and exposed as TalkBack actions).
* Dismissing the screen (back / swipe down) silences the alarm but leaves the todo **pending (Overdue)**; the notification stays in the shade.

## 12. Remind Me Later (Snooze)

Options:

```text
15 minutes
30 minutes
1 hour
2 hours
```

* Snooze is measured **from the moment the button is tapped** (due 7:00, tapped 7:05, "30 minutes" → 7:35).
* Snoozes are unlimited; each snoozed reminder repeats the full alarm behavior (§10).

## 13. Home-Screen Widget

```text
┌──────────────────────────┐
│ Today's Tasks            │
│                          │
│ 5:00 PM  Project Meeting │
│ 7:00 PM  DSA             │
│ 9:00 PM  Read            │
│                          │
│ + Add Todo               │
└──────────────────────────┘
```

* Shows **today's remaining incomplete todos**, ordered by time; completed items drop off.
* If fewer than 3 remain, tomorrow's earliest todos are appended under a "Tomorrow" label.
* Tapping a todo opens it in the app; **+ Add Todo** opens the app's chat input (widgets cannot take text input).
* Refreshes on any data change, at midnight, after reboot, and after snooze actions.

## 14. Natural-Language Todo Editing

```text
move dsa to 8pm
move meeting to tomorrow
change gym to 7am
```

Scope rules for **recurring** todos:

* **Time-only change** (`move dsa to 8pm`) → applies to the **whole series**.
* **Date change** (`move meeting to tomorrow`) → applies to the **single nearest occurrence** only.
* Explicit scope always wins: `move today's dsa to 8pm` → single occurrence; `move all gym to 7am` → series.
* If the AI is unsure of scope, it asks: `[ This one ] [ All future ]`.
* Unless stated otherwise, a date move keeps the same time.

## 15. Natural-Language Todo Completion

```text
finished dsa
done with project meeting
```

Matching rules (shared by edit, complete, and delete):

* Match against **pending occurrences** by title (exact first, then closest).
* If multiple candidates, prefer **today's occurrence**.
* If still ambiguous (e.g., two different todos match, or yesterday's and today's are both pending with no clear pick), show a one-tap disambiguation list.
* No match → "Couldn't find that todo" + offer to create it.

## 16. Natural-Language Todo Deletion

```text
delete dsa
cancel gym today
skip tomorrow's gym
```

* `delete <series>` removes the series' **future occurrences only**; completed/missed history is kept.
* `cancel/skip <occurrence>` removes just that occurrence.
* All NL deletions show a confirmation before executing.
* UI deletion is also available (long-press / swipe on a todo).

## 17. Smart Conflict Detection

* A conflict = two **incomplete** todos at the **same minute on the same day**.
* Checked at creation and edit time across the materialized 30-day window. A new recurring series that conflicts on some days shows one summarized prompt (e.g., "conflicts with Gym at 6:00 AM on Mon/Wed/Fri").

```text
[ Keep Both ]
[ Move New Task ]   → opens a time picker prefilled with the next free 30-minute slot
[ Cancel ]
```

## 18. Priority

```text
urgent submit assignment tomorrow 9am
→ Title: Submit assignment · Priority: HIGH · Tomorrow · 9 AM
```

* Supported: `LOW`, `MEDIUM`, `HIGH`. Default: `MEDIUM`.

## 19. Accounts & Sign-In

* **Google Sign-In** (Android Credential Manager) is the only auth method; the ID token is exchanged with **Supabase Auth** (signInWithIdToken), which issues the session used for all data access.
* The app is fully usable **signed out** (local-only mode): all of §23's offline features work with no account.
* Sign-in is required only for **cloud sync** and **collaboration rooms**.
* On first sign-in, local todos are uploaded and merged into the account.

## 20. Collaboration / Rooms

Room functionality:

* Create room, invite users (share link / room code), add/remove members
* Create shared todos, assign to members, set due date/time
* Recurring shared todos (completion tracked per occurrence)
* Track completion status, add comments, view activity history

Roles & permissions:

* Room **creator = admin**: manages membership, can delete the room or any task, can transfer admin.
* **Any member** can create, edit, assign, comment on, and complete tasks — every action is logged in activity history (§21).

Notifications:

* The **assignee's** device fires the full reminder (§10–11) for assigned tasks with due times.
* Other events arrive as standard FCM pushes: task assigned to you, comment on your task, your task completed by someone else.

Example:

```text
Project Room

Members: Tejas · Rahul · Amit

[ ] Build API   → Tejas   → 5 PM
[ ] Build UI    → Rahul   → 7 PM
[ ] Testing     → Amit    → Tomorrow
```

## 21. Collaboration Activity History

```text
10:32 AM  Rahul created "Build UI"
10:45 AM  Rahul assigned it to Tejas
11:20 AM  Tejas changed deadline to 6 PM
5:48 PM   Tejas completed "Build UI"
```

* Records: create, edit, assign, complete, delete, comment, member add/remove — with timestamp and actor. Append-only.

## 22. Backend Requirements (Supabase)

The backend is **Supabase** — managed Postgres, Auth, Edge Functions, and Realtime. No self-hosted server exists. Responsibilities:

* **Groq proxy** — a Supabase **Edge Function** is the only holder of the Groq API key (stored in function secrets, never in the APK); implements per-user rate limiting (counter table); returns validated JSON to the app.
* **Auth** — Supabase Auth with Google as the provider (§19); its session governs all data access.
* **Data & permissions** — personal todos (synced), rooms, membership, shared todos, comments, and activity history live in Supabase Postgres; every access rule from §19–20 (including admin-only membership control) is enforced with **Row Level Security** policies, accessed from the app via supabase-kt/PostgREST.
* **Live room updates** — **Supabase Realtime** streams shared-todo, comment, and membership changes to room members.
* **Activity history** — append-only table populated by database triggers on shared-todo mutations.
* **FCM sender** — Database Webhooks fire an **Edge Function** on relevant inserts (assignment, comment, completion), which sends the push via FCM.
* All traffic over TLS (Supabase default).

## 23. Offline Behavior & Sync

Works fully offline (local-only):

* View, create (manual form), edit, complete, and delete todos
* Recurring occurrence generation
* Local reminders and snoozing
* Widget updates

Natural-language input while offline:

* The raw text is saved to an **outbox queue** with a "Waiting for internet" status shown in the list.
* When connectivity returns, queued items are parsed automatically in order; anything needing confirmation prompts the user then.
* A queued item has **no reminder until it is parsed** — for anything time-critical while offline, use the manual add form.

Requires internet: NL parsing, cloud sync, collaboration.

Sync rules:

* **Room stays the on-device source of truth.** Sync is a hand-written layer over **supabase-kt** (PostgREST) between Room and Supabase — no third-party sync engine. (PowerSync is the upgrade path if hand-rolled sync ever becomes painful; it would replace Room.)
* Personal todos sync with **row-level last-write-wins by server timestamp**; a completed occurrence is never overwritten back to pending by a stale write.
* Shared-todo mutations made offline are queued and synced; activity history is append-only, so no room events are lost. Completion is idempotent.

## 24. AI Processing Flow

```text
User Input
    ↓
Supabase Edge Function (holds Groq key)
    ↓
Groq AI
    ↓
Structured JSON (intent-based)
    ↓
Validation Layer (on device)
    ↓
Confirmation if Required
    ↓
Todo Service
    ↓
Room DB
    ↓
Scheduler (AlarmManager / WorkManager)
    ↓
Android Notification
```

## 25. Example AI Output

Create — `dsa 7pm daily`:

```json
{
  "intent": "create",
  "title": "DSA",
  "date": "2026-08-23",
  "time": "19:00",
  "allDay": false,
  "recurrence": {
    "type": "daily",
    "interval": 1,
    "count": null,
    "endDate": null
  },
  "priority": "medium",
  "needsConfirmation": false
}
```

Edit — `move dsa to 8pm`:

```json
{
  "intent": "edit",
  "match": "dsa",
  "changes": { "time": "20:00" },
  "scope": "series",
  "needsConfirmation": false
}
```

Complete — `finished dsa`:

```json
{
  "intent": "complete",
  "match": "dsa",
  "needsConfirmation": false
}
```

* The app's validation layer checks every response before acting; `match` resolution follows §15.

## 26. Android Platform Requirements

* Runtime permissions & onboarding flow, in order:
  1. `POST_NOTIFICATIONS` (Android 13+)
  2. Exact alarms — `SCHEDULE_EXACT_ALARM` / `USE_EXACT_ALARM` (Android 12+)
  3. Full-screen intent permission (restricted on Android 14+; guide the user to grant it)
  4. **Battery-optimization exemption**, with OEM-specific guidance for Xiaomi / Oppo / Vivo / Realme — without this, scheduled reminders are silently killed on many devices.
* Reschedule all pending alarms on `BOOT_COMPLETED`.
* Times are stored and fired in the device's local timezone.

## 27. Screens

* **Home** — chat input pinned at the bottom; sections: Overdue → Today → Upcoming.
* **History** — Completed and Missed todos.
* **Rooms** — room list, room detail (tasks, comments, activity).
* **Settings** — account, Quiet reminders toggle, default times.
* **Fullscreen Reminder** (§11).

## 28. Non-Functional & Scope Boundaries

* Creation target: ≤ 5 s end-to-end including AI parse.
* Input language: **English only** (other languages are unsupported; untested even if the model happens to handle them).
* Not part of this app — excluded outright, not deferred: iOS/web, voice input, custom snooze durations, calendar integration, rotating assignments in rooms, todo durations/time-blocking.

## 29. Build Order (Single Phase)

There is no MVP cut and no feature deferral — the app is done only when every section above is done. The sequence below is purely the order of construction forced by dependencies; every step is in scope.

1. **Local core** — Room schema, todo service, recurrence engine with the 30-day materialization window, states/lifecycle, manual add form, Home and History screens.
2. **Reminders** — exact alarms, fullscreen reminder + snooze, permission/battery-exemption onboarding, boot rescheduling.
3. **Supabase setup** — Supabase project, Postgres schema + Row Level Security policies, Groq-proxy Edge Function with per-user rate limiting.
4. **NL pipeline** — chat input → proxy → validation layer → intent handling (create/edit/complete/delete), confirmation cards, offline outbox queue.
5. **Widget** — Glance widget with all refresh triggers.
6. **Accounts + sync** — Google Sign-In via Supabase Auth, hand-written Room↔Supabase sync layer (supabase-kt), local↔cloud merge, last-write-wins resolution.
7. **Collaboration** — rooms + RLS roles, shared todos, comments, Realtime live updates, trigger-driven activity history, webhook → Edge Function → FCM pushes.
8. **Hardening** — conflict detection across the window, missed-alarm recovery, OEM battery-killer testing on real Xiaomi/Oppo/Vivo devices, full end-to-end pass of §§1–27.
