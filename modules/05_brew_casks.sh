#!/usr/bin/env bash
################################################################################
# 05_brew_casks.sh
#
# Installs a list of brew cask applications if not already installed.
################################################################################

set -euo pipefail
trap 'echo -e "\n[ERROR] in 05_brew_casks.sh at line $LINENO. Exiting..." >&2' ERR

if ! command -v gum &>/dev/null; then
  echo "[ERROR] gum not found. Please run through the orchestrator."
  exit 1
fi

CASKS=(
  1password
  1password-cli
  adobe-creative-cloud
  alfred
  arc
  balenaetcher
  bartender
  beyond-compare
  brave-browser
  calibre
  chatgpt
  discord
  docker
  elgato-stream-deck
  firefox
  ghostty
  gitkraken
  google-chrome
  google-cloud-sdk
  handbrake
  iterm2
  jetbrains-toolbox
  kitty
  linear-linear
  microsoft-auto-update
  microsoft-edge
  microsoft-excel
  microsoft-onenote
  microsoft-outlook
  microsoft-powerpoint
  microsoft-teams
  microsoft-word
  mongodb-compass
  mysqlworkbench
  notion
  obs
  openlens
  openscad
  parallels-toolbox
  postman
  rar
  royal-tsx
  spotify
  steam
  sublime-text
  visual-studio-code
  vlc
  warp
  whatsapp
  zed
  zoom
)

################################################################################
# 1. Confirm user wants to proceed with cask installs
################################################################################
gum style --border normal --margin "1" --padding "1 2" --border-foreground 212 \
  "Installing Brew Cask Apps"

gum style --margin "1" --foreground 99 \
  "We will install the following cask apps:\n${CASKS[*]}"

if ! gum confirm "Proceed with installing these cask apps?"; then
  gum style --foreground 214 "Skipped installing Brew cask apps."
  exit 0
fi

################################################################################
# 2. Loop over each cask and install if missing
################################################################################
for CASK in "${CASKS[@]}"; do
  if brew list --cask | grep -q "^${CASK}\$"; then
    gum style --foreground "10" "Already installed: $CASK. Skipping..."
  else
    brew install --cask "$CASK"
  fi
done

exit 0
