#!/bin/bash
# Set up terminal environment: oh-my-zsh, zsh plugins, iTerm2 config.
# Usage: bash scripts/setup-terminal.sh

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
REPO_DIR="$(dirname "$SCRIPT_DIR")"

# -- Oh My Zsh --
if [ -d "$HOME/.oh-my-zsh" ]; then
  echo "✓ Oh My Zsh already installed"
else
  echo "Installing Oh My Zsh..."
  sh -c "$(curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)" "" --unattended
fi

# -- zsh-autosuggestions plugin --
ZSH_AUTOSUGGEST_DIR="${ZSH_CUSTOM:-$HOME/.oh-my-zsh/custom}/plugins/zsh-autosuggestions"
if [ -d "$ZSH_AUTOSUGGEST_DIR" ]; then
  echo "✓ zsh-autosuggestions already installed"
else
  echo "Installing zsh-autosuggestions..."
  git clone https://github.com/zsh-users/zsh-autosuggestions "$ZSH_AUTOSUGGEST_DIR"
fi

# -- zsh-syntax-highlighting plugin --
ZSH_SYNTAX_DIR="${ZSH_CUSTOM:-$HOME/.oh-my-zsh/custom}/plugins/zsh-syntax-highlighting"
if [ -d "$ZSH_SYNTAX_DIR" ]; then
  echo "✓ zsh-syntax-highlighting already installed"
else
  echo "Installing zsh-syntax-highlighting..."
  git clone https://github.com/zsh-users/zsh-syntax-highlighting "$ZSH_SYNTAX_DIR"
fi

# -- iTerm2 custom folder --
ITERM_PREFS_DIR="$REPO_DIR/terminal/iterm2"
CURRENT=$(defaults read com.googlecode.iterm2 PrefsCustomFolder 2>/dev/null || echo "")
if [ "$CURRENT" = "$ITERM_PREFS_DIR" ]; then
  echo "✓ iTerm2 custom folder already set"
else
  echo "Setting iTerm2 custom preferences folder..."
  defaults write com.googlecode.iterm2 PrefsCustomFolder -string "$ITERM_PREFS_DIR"
  defaults write com.googlecode.iterm2 LoadPrefsFromCustomFolder -bool true
  echo "  → Restart iTerm2 to apply settings"
fi
