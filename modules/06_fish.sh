#!/usr/bin/env bash
################################################################################
# 06_fish.sh
#
# Sets Fish as the default shell, installs fish plugins, etc.
################################################################################

set -euo pipefail
trap 'echo -e "\n[ERROR] in 06_fish.sh at line $LINENO. Exiting..." >&2' ERR

if ! command -v gum &>/dev/null; then
  echo "[ERROR] gum not found. Please run through the orchestrator."
  exit 1
fi

################################################################################
# 1. Check if Fish is installed
################################################################################
if ! command -v fish &>/dev/null; then
  gum style --foreground 196 "Fish is not installed. Please ensure it was installed in a previous step."
  gum style --foreground 214 "Skipping Fish setup."
  exit 0
fi

################################################################################
# 2. Set Fish as default shell (if not already)
################################################################################
CURRENT_SHELL=$(dscl . -read /Users/"$(whoami)" UserShell | awk '{print $2}')

if [[ "$CURRENT_SHELL" == *"/fish" ]]; then
  gum style --foreground "10" "Fish is already the default shell. Skipping..."
else
  gum style --border normal --margin "1" --padding "1 2" --border-foreground 212 \
    "Setting Fish as default shell"

  if gum confirm "Add /opt/homebrew/bin/fish to /etc/shells and chsh -s it now?"; then
    # Add fish to /etc/shells if not present
    if ! grep -qx "/opt/homebrew/bin/fish" /etc/shells; then
      sudo sh -c 'echo "/opt/homebrew/bin/fish" >> /etc/shells'
    fi

    # Switch default shell
    sudo chsh -s /opt/homebrew/bin/fish "$USER"
    gum style --foreground "10" "Fish is now your default shell (restart terminal to see effect)."
  else
    gum style --foreground 214 "Skipped changing default shell to Fish."
  fi
fi

################################################################################
# 3. Add brew path
################################################################################
if [[ "$(uname -m)" == "arm64" ]]; then
  FISH_HOMEBREW_PATH="/opt/homebrew/bin"
else
  FISH_HOMEBREW_PATH="/usr/local/bin"
fi

gum style --border normal --margin "1" --padding "1 2" --border-foreground 212 \
  "Adding Homebrew bin to Fish config..."

# Ensure ~/.config/fish exists
mkdir -p "${HOME}/.config/fish"

# Append a small snippet to config.fish if not already present
if ! grep -Fq "$FISH_HOMEBREW_PATH" "${HOME}/.config/fish/config.fish" 2>/dev/null; then
  echo "fish_add_path $FISH_HOMEBREW_PATH" >>"${HOME}/.config/fish/config.fish"
  gum style --foreground "10" "Added: fish_add_path $FISH_HOMEBREW_PATH to config.fish"
else
  gum style --foreground "10" "Path $FISH_HOMEBREW_PATH already in config.fish. Skipping..."
fi

################################################################################
# 4. Install fish plugins
################################################################################
gum style --border normal --margin "1" --padding "1 2" --border-foreground 212 \
  "Install Fish Plugins"

gum style --margin "1" --foreground 99 \
  "We'll install 'fisher' plugin manager and some common plugins (example)."

if gum confirm "Proceed with Fish plugin installation?"; then
  curl -sL https://raw.githubusercontent.com/jorgebucaran/fisher/main/functions/fisher.fish | source && fisher install jorgebucaran/fisher

  # Add whatever plugins you’d like:
  fish -c "fisher install jorgebucaran/nvm.fish"
  fish -c "fisher install IlanCosman/tide@v5"
  fish -c "fisher install PatrickF1/fzf.fish"
  fish -c "fisher install andreiborisov/sponge"
  fish -c "fisher install jethrokuan/z"
  fish -c "fisher install jorgebucaran/autopair.fish"

  gum style --foreground "10" "Fish plugins installed!"
else
  gum style --foreground 214 "Skipped Fish plugin installation."
fi

exit 0
