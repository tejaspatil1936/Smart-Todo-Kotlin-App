#!/usr/bin/env bash
# One-time Codespace setup: Android SDK (CLI only), Claude Code, Supabase CLI.
# Versions pinned below may need bumping over time — Claude Code can update them.
set -euo pipefail

# --- Android command-line SDK (no Android Studio needed) ---
sudo mkdir -p /opt/android-sdk && sudo chown -R "$USER" /opt/android-sdk
cd /tmp
curl -sSLo cmdtools.zip https://dl.google.com/android/repository/commandlinetools-linux-11076708_latest.zip
unzip -q cmdtools.zip -d /opt/android-sdk/cmdline-tools
mv /opt/android-sdk/cmdline-tools/cmdline-tools /opt/android-sdk/cmdline-tools/latest
export PATH="$PATH:/opt/android-sdk/cmdline-tools/latest/bin:/opt/android-sdk/platform-tools"
yes | sdkmanager --licenses > /dev/null || true
sdkmanager "platform-tools" "platforms;android-35" "build-tools;35.0.0" > /dev/null
{
  echo 'export ANDROID_HOME=/opt/android-sdk'
  echo 'export PATH="$PATH:/opt/android-sdk/cmdline-tools/latest/bin:/opt/android-sdk/platform-tools"'
} >> "$HOME/.bashrc"

# --- Claude Code (native installer) ---
curl -fsSL https://claude.ai/install.sh | bash

# --- Supabase CLI ---
curl -fsSL https://github.com/supabase/cli/releases/latest/download/supabase_linux_amd64.tar.gz \
  | tar -xz -C /tmp && sudo mv /tmp/supabase /usr/local/bin/supabase

echo "Setup complete. Run:  claude"
