#!/usr/bin/env bash
################################################################################
# 07_macos_settings.sh
#
# Applies various macOS defaults settings (idempotent in the sense that re-applying
# won't harm anything).
################################################################################

set -euo pipefail
trap 'echo -e "\n[ERROR] in 07_macos_settings.sh at line $LINENO. Exiting..." >&2' ERR

if ! command -v gum &>/dev/null; then
  echo "[ERROR] gum not found. Please run through the orchestrator."
  exit 1
fi

################################################################################
# 1. Confirm user wants to proceed
################################################################################
gum style --border normal --margin "1" --padding "1 2" --border-foreground 212 \
  "Apply macOS Settings"

gum style --margin "1" --foreground 99 \
  "We'll apply various defaults write commands to configure macOS preferences."

if ! gum confirm "Proceed with applying macOS settings?"; then
  gum style --foreground 214 "Skipped macOS settings."
  exit 0
fi

################################################################################
# 2. Apply your macOS settings
################################################################################
gum spin --spinner line --title "Applying macOS settings..." -- sleep 1

# Example set of changes (customize to your liking)

# Expand save panel by default
defaults write NSGlobalDomain NSNavPanelExpandedStateForSaveMode -bool true
defaults write NSGlobalDomain PMPrintingExpandedStateForPrint -bool true
defaults write NSGlobalDomain PMPrintingExpandedStateForPrint2 -bool true

# Save to disk (not iCloud) by default
defaults write NSGlobalDomain NSDocumentSaveNewDocumentsToCloud -bool false

# Check for software updates daily
defaults write com.apple.SoftwareUpdate ScheduleFrequency -int 1

# Show filename extensions in Finder
defaults write NSGlobalDomain AppleShowAllExtensions -bool true

# Use column view in Finder by default
defaults write com.apple.finder FXPreferredViewStyle Clmv

# Avoid creating .DS_Store files on network volumes
defaults write com.apple.desktopservices DSDontWriteNetworkStores -bool true

# Dock icon size
defaults write com.apple.dock tilesize -int 36

# Speed up Mission Control animations
defaults write com.apple.dock expose-animation-duration -float 0.1

# Group windows by application in Mission Control
defaults write com.apple.dock expose-group-by-app -bool true

# Disable automatic rearranging of Spaces
defaults write com.apple.dock mru-spaces -bool false

# Restart Finder and Dock to apply changes
killall Finder || true
killall Dock || true

gum style --foreground "10" "macOS settings applied!"

exit 0
