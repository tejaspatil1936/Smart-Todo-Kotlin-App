# CLOUD-SETUP.md — Building without a capable laptop (GitHub Codespaces)

Your laptop only needs a **browser**. The Codespace does all compiling; your
**physical phone** is the test device (this app's critical testing — alarms,
lockscreen, battery killers — requires a real phone anyway).

## One-time setup

1. Create a **private GitHub repo**, upload this whole folder, commit to `main`.
2. Repo → Code → Codespaces → ⋯ → "New with options" → machine type
   **4-core / 16 GB** → create. First boot takes ~5 min while
   `.devcontainer/setup.sh` installs the Android SDK, JDK 17, Claude Code,
   and the Supabase CLI.
3. In the Codespace terminal: `claude` → open the login URL it prints →
   `/init` → fold HANDOFF.md's rules into CLAUDE.md → paste the kickoff
   prompt from HANDOFF.md. From here the build follows §29 exactly as if
   local.

## Getting each build onto your phone

**Route A — quick (no setup):**
```bash
./gradlew assembleDebug
cd app/build/outputs/apk/debug && python3 -m http.server 8000
```
Ports panel → port 8000 → visibility **Public** → open the forwarded URL on
your phone → tap the APK → install. (First time: allow "install unknown
apps" for your browser.)

**Route B — Actions:** every push to `main` builds the APK automatically
(`.github/workflows/build-apk.yml`); download it from the run's Artifacts
on your phone. Free 2,000 Actions minutes/month — use this for routine
builds to save Codespace hours.

**Route C — power loop (recommended from build step 2 onward):**
Tailscale bridges your phone and the Codespace so real `adb` works from
the cloud:
1. Install Tailscale on the phone (Play Store) and in the Codespace
   (`curl -fsSL https://tailscale.com/install.sh | sh && sudo tailscale up`),
   same account.
2. Phone: Developer options → **Wireless debugging** → Pair device with
   pairing code.
3. Codespace: `adb pair <phone-tailscale-ip>:<pairing-port>` then
   `adb connect <phone-tailscale-ip>:<debug-port>`.
4. Now `./gradlew installDebug` deploys straight to the phone and
   `adb logcat` streams live — essential when debugging alarms.

## Quota survival (free tier: 120 core-hours + 15 GB storage / month)

- A 4-core machine = **30 hours/month** free. Stop the Codespace the moment
  you finish (default idle timeout is 30 min; you can lower it).
- Keep exactly **one** Codespace; stopped ones still consume the storage
  quota. Deleting and recreating is cheap — setup.sh rebuilds everything.
- Leave the spending limit at $0 to guarantee you're never charged (work
  pauses until the monthly reset), or allow a small overage: $0.18/core-hour.
- Let Actions do routine builds; spend Codespace hours on Claude Code
  sessions.

## Unchanged from HANDOFF.md

Supabase/Groq/Firebase console work, all phone-side verification, the §29
order, and BUILD-SPEC.md's definitions of done are identical to a local
build. Skip emulators entirely — the phone is the device.
