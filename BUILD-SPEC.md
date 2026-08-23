# BUILD-SPEC.md — Engineering Decisions (assumption-free)

This file exists so Claude Code never has to invent anything. requirements.md says **what** the app does; this file pins **how** — schemas, contracts, algorithms, tokens, names, and conventions. If something is genuinely not covered here or in requirements.md, **ask the user; never assume, never add features.**

Precedence: `requirements.md` > `BUILD-SPEC.md` > `HANDOFF.md Spec Overrides` > `screens/*.png` > `code.html`.

---

## 1. Identity & configuration

- App display name: **Ink** · applicationId: **`com.inktodo.app`** (user may rename once, in step 1 only).
- minSdk **26**, target/compile SDK: latest stable. Kotlin latest stable, Jetpack Compose with BOM, single Gradle module `:app`, Kotlin DSL, version catalog (`libs.versions.toml`).
- Package layout: `com.inktodo.app.{data(db|remote|repo), domain(model|recurrence|parse), ui(theme|home|history|rooms|settings|reminder|onboarding|components), alarm, sync, widget, di}`.
- Secrets/config: `local.properties` → BuildConfig: `SUPABASE_URL`, `SUPABASE_ANON_KEY`. `google-services.json` in `app/` (step 6+). Server-side secrets (Groq key, FCM service account) live ONLY in Supabase function secrets. Never commit any key.
- Library allowlist (latest stable of each; anything else requires asking): Compose + Navigation, Hilt, Room, WorkManager, DataStore (settings), kotlinx-serialization, kotlinx-datetime or java.time (use **java.time**), supabase-kt (auth, postgrest, realtime, functions), Ktor client (supabase-kt engine), Firebase Messaging, Glance, Coil (not needed unless avatars become images — initials only for now, so skip Coil).

## 2. Design tokens (implementation values)

Bundle fonts in `res/font`: **Instrument Sans** (regular 400, medium 500, semibold 600) and **JetBrains Mono** (regular, medium). Mono is used for every time and number, tabular.

Colors (single dark theme; no dynamic color):
`ground #0C0C0C · surface #161616 · raised #1E1E1E · hairline #262626 · stroke #333333 · disabled #5C5C5C · textSecondary #A3A3A3 · textPrimary #F5F5F5 · inverted surface #F5F5F5 with #0C0C0C text · secondaryOnLight #4A4A4A · reminderTrack #E4E4E4`

Type scale (sp): display 96–112 (reminder time only) · title 28 · heading 20 · body 15 · label 13 (uppercase, +8% tracking) · caption 12 · timeRail 15 mono medium.

Dimensions (dp): screen gutters 24 · 8pt spacing grid · todo row height 64 · time-rail width 88 · checkbox 24 (1.5dp #5C5C5C stroke) · buttons 56 high, pill, full-width-minus-48 · chips 32 high, radius 16 · cards radius 16 · sheets top radius 24, drag handle 32×4 · bottom nav 80 · slide-control track 72 high / circles+puck 56 · widget 4×2, panel radius 24, inner padding 16.

State encoding (no hue anywhere): overdue = time in inverted tag + semibold title · due-next = the one inverted "Up Next" card (with 3dp solid #0C0C0C bar on its left inner edge) · completed = thin check + strikethrough + 40% alpha · priority = 3dp left-edge bar (HIGH #F5F5F5, MEDIUM #5C5C5C, LOW none) + outlined chip on cards · recurring = ↻ icon · queued = dashed 1dp #333333 border + cloud-off. Exactly one inverted element per region. Priority chips uppercase ("HIGH"); nav labels sentence case.

## 3. Room data model (on-device source of truth)

All ids are client-generated UUID strings. All timestamps epoch millis UTC; wall-clock fields kept separately (see §7 timezones). Every synced table has: `updatedAt: Long`, `deletedAt: Long?` (tombstone), `dirty: Boolean`.

```
TodoSeries(
  id, title, priority ∈ {LOW,MEDIUM,HIGH},
  allDay: Boolean, timeMinutes: Int?          // minutes from midnight, null iff allDay
  recurrenceType ∈ {NONE,DAILY,WEEKDAYS,WEEKLY,SPECIFIC_DAYS,MONTHLY,EVERY_N},
  intervalDays: Int?                          // EVERY_N only
  daysOfWeek: Int?                            // SPECIFIC_DAYS bitmask, bit0=Mon … bit6=Sun
  monthDay: Int?                              // MONTHLY: 1–31 (clamped at generation)
  startDate: LocalDate, endDate: LocalDate?,  // endDate inclusive
  count: Int?,                                // total occurrences incl. first; endDate XOR count XOR neither
  roomId: String?,                            // null = personal
  assigneeUserId: String?,                    // shared only
  createdAt, updatedAt, deletedAt, dirty
)
Occurrence(
  id, seriesId, date: LocalDate, dueAt: Long?,   // null for allDay
  state ∈ {PENDING,COMPLETED,MISSED}, completedAt: Long?, completedBy: String?,
  snoozedUntil: Long?,
  overrideDate: LocalDate?, overrideTimeMinutes: Int?,  // single-occurrence edits (§14 rules)
  updatedAt, deletedAt, dirty
)
NlOutboxItem(id, rawText, createdAt, status ∈ {WAITING,PARSING,NEEDS_CONFIRMATION,FAILED})
Room_(id, name, inviteCode, createdBy, createdAt, updatedAt, deletedAt, dirty)  // cloud cache
RoomMember(roomId, userId, displayName, role ∈ {ADMIN,MEMBER})
Comment(id, todoSeriesId, roomId, authorId, authorName, text, createdAt)
ActivityEntry(id, roomId, actorName, text, type, createdAt)
Settings via DataStore: quietReminders(false), morningDefault(540), eveningDefault(1080), allDayReminder(540)
```
Indices: Occurrence(seriesId), Occurrence(date), Occurrence(state,date), TodoSeries(roomId).
"Overdue" is a computed display state: `PENDING && dueAt < now && date == today` (one-offs stay overdue across days until acted on; see §6 midnight rule).

## 4. Recurrence engine (exact semantics)

- Anchor `startDate` = explicit parsed date, else today, adjusted by §6 of requirements (past-time → recurring starts at next valid occurrence, silently).
- Generation window: `today .. today+30d`. Regenerate: on app open, after any series create/edit/delete, and via a daily WorkManager job (see §6). Generation is idempotent — never duplicate an (seriesId,date); never touch occurrences with state ≠ PENDING or with overrides.
- DAILY: every day. WEEKDAYS: Mon–Fri. WEEKLY: same weekday as startDate. SPECIFIC_DAYS: bitmask days. EVERY_N: startDate, startDate+N, +2N… MONTHLY: `monthDay` each month, clamped to the month's last day (31 → Feb 28/29), returning to `monthDay` after.
- End: occurrences with date ≤ endDate (inclusive); or first `count` occurrences; NONE-type series produce exactly one occurrence at startDate.
- Edits (requirements §14): time-only change → update series `timeMinutes`, regenerate all FUTURE `PENDING` non-overridden occurrences (past + completed untouched). Single-occurrence date/time move → set `overrideDate`/`overrideTimeMinutes` on that occurrence only. Series delete → set series tombstone, hard-delete future PENDING occurrences, keep COMPLETED/MISSED. Occurrence skip/cancel → tombstone that occurrence.
- `dueAt` = zoned epoch of (effective date, effective time) in the device timezone at generation; recomputed for all future PENDING occurrences on `ACTION_TIMEZONE_CHANGED`.

## 5. Time & parsing defaults (validation layer mirrors these)

Bare 1–11 → PM · `12` → 12:00 · explicit am/pm respected · 24h `17:00` respected · `h:mm` without meridiem → PM · morning 09:00 · noon 12:00 · afternoon 15:00 · evening 18:00 · night/tonight 21:00 · no time → allDay=true (all-day notification at `allDayReminder` setting, standard notification, never fullscreen) · no date+no time → allDay today.
Validation layer (client, after Edge Function): reject unless — title 1–120 chars; date within today−1y..today+2y; timeMinutes 0–1439 or null with allDay; enums valid; EVERY_N has intervalDays 2–365; SPECIFIC_DAYS bitmask 1–127; count 1–1000; endDate ≥ startDate. On reject → treat as parse failure (toast "Couldn't understand that" + keep text in input).

## 6. Background jobs & state machine

- **Midnight job**: daily WorkManager (also run on app open if last run < today) at ~00:05 local: (a) recurring occurrences with date < today and state PENDING → MISSED; one-off (NONE) occurrences stay PENDING (display Overdue); (b) trigger regeneration; (c) widget update.
- State transitions only: PENDING→COMPLETED (Done/NL/checkbox), PENDING→MISSED (midnight, recurring only), COMPLETED→PENDING (undo/uncheck). MISSED is terminal except manual re-complete allowed from History → COMPLETED.

## 7. Timezones

All user-facing times are wall-clock local. Persist LocalDate + minutes-from-midnight as canon; `dueAt` is derived. On timezone/DST change broadcast: recompute future `dueAt`s and reschedule the alarm.

## 8. Alarms & notifications (implementation contract)

- Schedule ONLY the next upcoming reminder with **`AlarmManager.setAlarmClock`** (survives Doze, correct semantics for an alarm app). After it fires — or after any data change, boot (`BOOT_COMPLETED`), snooze, or timezone change — recompute and schedule the next one. Occurrences sharing the same due minute fire as ONE reminder listing all.
- On fire: start a foreground service (type `shortService`/`mediaPlayback`) that posts a notification on channel `reminders` (IMPORTANCE_HIGH, no channel sound) with a **full-screen intent** to `ReminderActivity` (`setShowWhenLocked`, `setTurnScreenOn`), and plays the alarm via Ringtone/MediaPlayer on **STREAM_ALARM** + vibration, hard-stopped at **60s**. Notification stays until action. Quiet-reminders setting ON → skip fullscreen/sound/vibration; post a normal high-priority notification instead.
- ReminderActivity slide control: drag right past 85% of travel → COMPLETED; left past 85% → snooze sheet; end circles tappable (48dp) with TalkBack actions "Done"/"Remind me later". Back/dismiss → stop sound, occurrence stays PENDING, notification remains.
- Snooze: exact alarm at `tapTime + Δ` (15/30/60/120 min), unlimited, full alarm behavior each time; store `snoozedUntil`.
- Missed while off (§10 of requirements): at boot/unlock, if a due reminder is < 60 min late → fire immediately as standard notification (short sound, no fullscreen); older → silent, states per §6.
- All-day todos: standard notification at the `allDayReminder` time, no alarm behavior.

## 9. Supabase auth model

- First NL parse (or first sync/room action) with no session → create a **Supabase anonymous session** (`signInAnonymously`). This gives every device a `user_id` for rate limiting without an account.
- Google sign-in (§19): Credential Manager ID token → if current session is anonymous, **`linkIdentity`** to upgrade it (data keeps the same user_id); else `signInWithIdToken`. On first Google sign-in, push all local personal data (initial sync).
- Signed-out + offline: manual form only (already per requirements). Signed-out + online: NL works via the anonymous session.

## 10. Supabase schema (Postgres)

All synced tables: `id uuid pk`, `user_id uuid default auth.uid()`, `updated_at timestamptz` (set by trigger on every write), `deleted_at timestamptz null`. Enable RLS on every table.

```
todos      — mirrors TodoSeries (room_id uuid null references rooms, assignee_user_id uuid null)
occurrences— id, series_id fk, date, state, completed_at, completed_by, override_date, override_time_minutes
rooms      — id, name, invite_code text unique, created_by
room_members — room_id fk, user_id, display_name, role text check in ('admin','member'), pk(room_id,user_id)
comments   — id, todo_series_id fk, room_id fk, author_id, author_name, text, created_at
activity   — id, room_id fk, actor_name, type text, text, created_at   (append-only; INSERT via trigger only)
nl_usage   — user_id, day date, count int, pk(user_id, day)
fcm_tokens — user_id, token text, updated_at, pk(user_id, token)
```

RLS policies (exact intent):
- `todos`/`occurrences`: select/insert/update where `user_id = auth.uid()` **OR** (`room_id` is not null AND requester is in `room_members` for that room). Any member may update shared todos (all changes logged); only admin or owner may delete shared todos.
- `rooms`: select if member; insert by anyone (creator auto-inserted as admin via trigger); update/delete only by admin.
- `room_members`: select if member of the same room; insert self only via valid `invite_code` (SECURITY DEFINER function `join_room(code)`); delete = self (leave) or admin (remove); admin cannot be removed.
- `comments`: select/insert if member; no update; delete by author or admin.
- `activity`: select if member; no direct insert/update/delete from clients.
- `nl_usage`, `fcm_tokens`: owner only.
Triggers: `set_updated_at` on all synced tables; `log_activity` AFTER INSERT/UPDATE on todos+occurrences+comments where room_id is not null (types: created/assigned/deadline_changed/completed/comment); `room_creator_is_admin` AFTER INSERT on rooms.
Realtime: publication on todos, occurrences, comments, activity; client subscribes with `room_id=eq.{id}` filters while a room screen is open.

## 11. Edge Functions (TypeScript)

**`parse-todo`** — POST, requires Supabase JWT (anonymous ok).
Request: `{ "text": string, "now": {"date":"YYYY-MM-DD","time":"HH:mm","weekday":"monday",tz:"Asia/Kolkata"} }`
Behavior: bump `nl_usage` (reject > **50/day** with 429 `{"error":{"code":"rate_limited"}}`); call Groq — model **`llama-3.3-70b-versatile`** (verify current recommended fast model on the Groq console at implementation), `temperature: 0`, `response_format: {"type":"json_object"}` — with the system prompt in §12; return Groq's JSON verbatim on success, else 422 `{"error":{"code":"parse_failed"}}`.
Response schemas (exhaustive — no other fields):
```
create:   {intent:"create", title, date:"YYYY-MM-DD", time:"HH:mm"|null, allDay:bool,
           recurrence:{type:"none|daily|weekdays|weekly|specific_days|monthly|every_n",
                       intervalDays:int|null, daysOfWeek:["monday",…]|null, monthDay:int|null,
                       endDate:"YYYY-MM-DD"|null, count:int|null},
           priority:"low|medium|high", needsConfirmation:bool, note:string|null}
edit:     {intent:"edit", match:string, changes:{time?:"HH:mm", date?:"YYYY-MM-DD",
           title?:string, priority?:string}, scope:"series|single|unknown", needsConfirmation:bool}
complete: {intent:"complete", match:string}
delete:   {intent:"delete", match:string, scope:"series|single", date:"YYYY-MM-DD"|null}
unknown:  {intent:"unknown"}
```
`note` carries the past-time message ("Moved to tomorrow — 5:00 PM today has already passed"). The client's validation layer (§5) re-checks everything; the app never trusts the model.

**`send-push`** — triggered by a Database Webhook on `activity` INSERT. Loads room members' `fcm_tokens` (excluding the actor), sends FCM HTTP v1 (service-account JSON in function secrets) for types: assigned-to-you, comment-on-your-task, your-task-completed. Assigned tasks with due times ring the full local alarm on the assignee's device (local scheduling after sync — no push needed for the alarm itself).

## 12. Groq system prompt (use verbatim in `parse-todo`)

```
You convert one short todo command into JSON. Reply with ONLY a single JSON
object, no prose. Today is {date} ({weekday}), current time {time}, timezone
{tz}. Schemas: [create/edit/complete/delete/unknown exactly as documented in
the function]. Rules: intent is "edit" for move/change/reschedule wording,
"complete" for finished/done wording, "delete" for delete/cancel/skip
wording, else "create"; "unknown" only if it is not a todo command at all.
Times: bare numbers 1-11 are PM; 12 means noon; morning=09:00, noon=12:00,
afternoon=15:00, evening=18:00, night or tonight=21:00; "h:mm" without
am/pm is PM; 24h accepted. No time mentioned → time=null and allDay=true.
No date → today. Recurrence: map daily/weekdays/every <weekday>/monthly/
every N days/specific weekday lists; "for N days" → endDate = start+N days;
"until <date>" → endDate; "N times" → count. If a one-off's parsed time is
already past today, use tomorrow and set note to "Moved to tomorrow —
<time> today has already passed". priority defaults to "medium"; words like
urgent/important/asap → high, "low priority"/whenever → low. Title: the
task words only, cleaned, max 6 words, original casing of proper nouns.
needsConfirmation=true only when you had to guess something not covered by
these rules (vague words like "later", conflicting info, unclear title) or
when note is set. For edit: scope="series" for time-only changes,
"single" for date moves or when "today's/tomorrow's" is specified,
"unknown" if unclear.
```

## 13. Sync protocol (refines requirements §23)

- Scope: `todos` + `occurrences` where `room_id` is null (personal), both directions; shared data is fetched per-room (list on Rooms screen open, live via Realtime while inside).
- Push: rows with `dirty=1` → PostgREST upsert (client sends its fields; server trigger stamps `updated_at`); on success clear `dirty`.
- Pull: `updated_at > last_pulled_at` cursor per table (stored in DataStore); apply to Room.
- Conflict: **row-level last-write-wins by server `updated_at`** — with one carve-out: an occurrence `state=COMPLETED` is never overwritten back to PENDING by a stale row. Deletes propagate as `deleted_at` tombstones both ways; tombstones purge locally after 30 days.
- Runs: on app foreground, after local mutations (debounced 5s), and a periodic 6h WorkManager job. Offline shared-todo mutations queue exactly like personal ones (dirty rows) and push on reconnect.

## 14. Navigation & screens

Compose Navigation routes: `home` (start) · `history` · `rooms` · `rooms/{roomId}` · `settings` · `signin` · `onboarding` (4-page pager, shown once before first reminder is scheduled) — plus dialogs/sheets (manual add, AI confirmation, disambiguation, snooze, conflict, task detail, create room) as bottom sheets/dialogs, not routes. `ReminderActivity` is a separate activity (lockscreen). Bottom nav on the four tab screens only. Every visible string comes from the screens/ set and the two SPEC.md files — no invented copy.

## 15. Definition of done per §29 step (stop after each; user verifies)

1. Local core: recurrence unit tests green (monthly 31st→Feb clamp, EVERY_N anchoring, "for 30 days" inclusive end, count semantics, weekdays, idempotent regeneration); manual-form todo appears in Home sections correctly; History shows completed/missed; app runs on emulator.
2. Reminders: on a REAL device — todo due in 2 min rings through lock screen with slide control; Done completes; snooze re-rings; reboot preserves the alarm; quiet-toggle downgrades; same-minute todos = one reminder.
3. Supabase: schema + RLS applied via migration SQL in repo (`supabase/` dir); `parse-todo` deployed; curl with a JWT parses `dsa 7pm daily` correctly; 51st call in a day returns 429.
4. NL pipeline: typing each example from requirements §2 creates the right todo; ambiguous input shows confirmation sheet; `finished dsa` with two matches shows disambiguation; airplane-mode input queues and parses on reconnect.
5. Widget: shows today's remaining, updates on complete/midnight/boot, + opens input.
6. Accounts+sync: Google sign-in links; uninstall/reinstall + sign-in restores todos; edit on device A appears on B after sync.
7. Collaboration: second device joins via code; assignment pushes FCM to assignee; assigned due task rings assignee's alarm; activity tab matches actions; non-member gets RLS-denied.
8. Hardening: §17 conflict dialog paths; missed-alarm recovery; battery-killer survival on a Xiaomi/Oppo/Vivo device; full pass of requirements §§1–28.

## 16. The user provides (only these, when the step needs them)

Step 3: Supabase project URL + anon key; Groq API key (into `supabase secrets set`). Step 6: SHA-1 debug+release fingerprints, Google OAuth client, `google-services.json`. Step 7: Firebase service-account JSON (into function secrets). Nothing else is external.

## 17. Conventions

Coroutines + Flow end-to-end; repositories expose Flow; no LiveData. Hilt for DI. One ViewModel per screen. Errors surface as snackbars using existing copy tone. Commit after every green sub-task with conventional messages (`feat: recurrence engine window regeneration`). Write unit tests for: recurrence, parse-validation layer, sync merge, midnight job. No analytics, no crash SDK, no ads, no extra libraries, no iOS/web — ever, without asking.
