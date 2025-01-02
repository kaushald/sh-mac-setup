#!/usr/bin/env bash
################################################################################
# 01_xcode.sh
#
# Installs Xcode CLI tools if not already installed.
#
# Idempotency Check: Uses `xcode-select -p` to see if CLI tools are installed.
################################################################################

set -euo pipefail
trap 'echo -e "\n[ERROR] in 01_xcode.sh at line $LINENO. Exiting..." >&2' ERR

# Confirm user has gum installed by now (should be guaranteed by orchestrator)
if ! command -v gum &>/dev/null; then
  echo "[ERROR] gum not found. Please run through the orchestrator."
  exit 1
fi

################################################################################
# 1. Check if Xcode CLI Tools are installed
################################################################################
if xcode-select -p &>/dev/null; then
  gum style --border normal --margin "1" --padding "1 2" --border-foreground "10" \
    "Xcode Command Line Tools are already installed. Skipping..."
  exit 0
fi

################################################################################
# 2. Prompt user to install
################################################################################
gum style --border normal --margin "1" --padding "1 2" --border-foreground 212 \
  "Xcode Command Line Tools not found."

gum style --margin "1" --foreground 99 \
  "We'll run 'xcode-select --install' to initiate the installation.\n" \
  "A GUI popup may appear; follow on-screen instructions."

if gum confirm "Proceed with Xcode CLI Tools installation?"; then
  gum spin --spinner line --title "Installing Xcode CLI Tools..." -- \
    xcode-select --install

  gum style --foreground "10" "Installation triggered. Please follow any popups."
  gum style --margin "1" --foreground 99 \
    "We'll do a quick wait-and-check. If the user manually cancels, step will remain incomplete."

  # (Optional) Wait a few seconds before checking again, just to show something
  sleep 5
  if xcode-select -p &>/dev/null; then
    gum style --foreground "10" "Xcode CLI Tools are now installed!"
  else
    gum style --foreground "214" "Installation not confirmed yet. You may need to rerun."
  fi
else
  gum style --foreground "214" "User skipped Xcode CLI Tools installation."
fi

exit
