#!/bin/bash
# Set up this Mac from the repo by running every setup step in order.
# Each step skips work that is already done, so re-running is safe.
# Usage: ./setup.sh

set -euo pipefail

REPO_DIR="$(cd "$(dirname "$0")" && pwd)"
SCRIPTS_DIR="$REPO_DIR/scripts"

step() {
  printf '\n==> %s\n' "$1"
}

if [ "$(uname -s)" != "Darwin" ]; then
  echo "✗ setup.sh only supports macOS" >&2
  exit 1
fi

step "Homebrew"
if [ -x /opt/homebrew/bin/brew ]; then
  echo "✓ Homebrew already installed"
else
  /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
fi
eval "$(/opt/homebrew/bin/brew shellenv)"

step "Brewfile"
brew bundle --file="$REPO_DIR/Brewfile"

step "Node.js (fnm)"
eval "$(fnm env)"
if fnm list 2>/dev/null | grep -q 'v'; then
  echo "✓ Node.js already installed"
else
  fnm install --lts
fi
fnm default lts-latest >/dev/null 2>&1 || true
# Re-evaluate so node points at the default version set above.
eval "$(fnm env)"

# Must run before link-configs.js: the Oh My Zsh installer replaces ~/.zshrc
# and refuses to install into an existing ~/.oh-my-zsh.
step "Terminal"
bash "$SCRIPTS_DIR/setup-terminal.sh"

step "Symlinks"
node "$SCRIPTS_DIR/link-configs.js"

step "Git hooks"
git -C "$REPO_DIR" config core.hooksPath hooks
echo "✓ core.hooksPath = hooks"

step "Herdr App mods"
NOTIFICATIONS_MOD_DIR="$HOME/.config/herdr-app/mods/desktop-notifications"
if [ -d "$NOTIFICATIONS_MOD_DIR" ]; then
  echo "✓ desktop-notifications already installed"
else
  HERDR_MODS_TMP="$(mktemp -d)"
  git clone --depth 1 https://github.com/benjaminsicard/herdr-mods.git "$HERDR_MODS_TMP"
  mkdir -p "$(dirname "$NOTIFICATIONS_MOD_DIR")"
  cp -R "$HERDR_MODS_TMP/desktop-notifications/mods/desktop-notifications" "$NOTIFICATIONS_MOD_DIR"
  rm -rf "$HERDR_MODS_TMP"
  echo "✓ desktop-notifications installed"
fi

QUEUE_APP_DIR="${HERDR_APP_HOME:-$HOME/.config/herdr-app}"
QUEUE_MOD_DIR="$QUEUE_APP_DIR/mods/queue"
if [ -f "$QUEUE_MOD_DIR/main.js" ]; then
  echo "✓ Queue already installed"
elif [ -e "$QUEUE_MOD_DIR" ] || [ -L "$QUEUE_MOD_DIR" ]; then
  printf 'Queue install path already exists: %s\n' "$QUEUE_MOD_DIR" >&2
  exit 1
else
  (
    QUEUE_UPSTREAM="https://github.com/Lakris2407/herdr-mods.git"
    QUEUE_REVISION="b6fdb2ffb1207f8f686dffdd6addc19fe696d435"
    mkdir -p "$QUEUE_APP_DIR/mods"
    QUEUE_STAGE="$(mktemp -d "$QUEUE_APP_DIR/.queue-install.XXXXXXXX")"
    trap 'rm -rf "$QUEUE_STAGE"' EXIT

    git -C "$QUEUE_STAGE" init --quiet
    git -C "$QUEUE_STAGE" fetch --quiet --depth 1 "$QUEUE_UPSTREAM" "$QUEUE_REVISION"
    mkdir "$QUEUE_STAGE/queue"
    git -C "$QUEUE_STAGE" archive "$QUEUE_REVISION:queue/mods/queue" | tar -xf - -C "$QUEUE_STAGE/queue"
    test -f "$QUEUE_STAGE/queue/main.js"
    mv -n "$QUEUE_STAGE/queue" "$QUEUE_APP_DIR/mods/"
    test -f "$QUEUE_MOD_DIR/main.js"
    echo "✓ Queue installed"
  )
fi

step "Collie"
if [ -x "$HOME/.local/bin/collie" ]; then
  echo "✓ Collie already installed"
else
  sh -c "$(curl -fsSL https://colliepwa.dev/install.sh)"
fi

step "VS Code extensions"
node "$SCRIPTS_DIR/install-extensions.js"

cat <<'EOF'

Done. Remaining manual steps:
  - Restart iTerm2 to load the custom preferences folder
  - Allow terminal-notifier in System Settings → Notifications
  - Run `exec zsh` to reload the shell
  - Sign in to Tailscale and pair Collie (see README)
EOF
