#!/usr/bin/env bash

################################################################################
# orchestrator.sh
#
# This script bootstraps a new Mac environment by:
#   1) Installing Homebrew (if missing).
#   2) Installing Gum (if missing).
#   3) Calling each module script in a "modules/" directory in sequence, using Gum
#      for a fancy UI to confirm or skip steps.
#
# Logging, error handling, and idempotency are included.
################################################################################

# Exit immediately on errors, treat unset variables as errors, fail on pipeline errors
set -euo pipefail

# Trap to display a helpful error if something goes wrong
trap 'echo -e "\n[ERROR] at line $LINENO. Exiting..." >&2' ERR

################################################################################
# OPTIONAL LOGGING
################################################################################
# Comment these lines if you do not want all output logged to a file as well as printed.

LOG_FILE="${HOME}/mac_setup.log"
exec > >(tee -a "${LOG_FILE}") 2>&1

################################################################################
# 1. CHECK/INSTALL HOMEBREW
################################################################################
install_homebrew_if_needed() {
  if command -v brew &>/dev/null; then
    echo "[INFO] Homebrew is already installed. Skipping..."
  else
    echo "[INFO] Homebrew not found. Installing..."
    /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"

    # Initialize Brew in the user's environment
    if [[ "$(uname -m)" == "arm64" ]]; then
      echo 'eval "$(/opt/homebrew/bin/brew shellenv)"' >> "${HOME}/.zprofile"
      eval "$(/opt/homebrew/bin/brew shellenv)"
    else
      echo 'eval "$(/usr/local/bin/brew shellenv)"' >> "${HOME}/.zprofile"
      eval "$(/usr/local/bin/brew shellenv)"
    fi

    echo "[INFO] Homebrew installation complete."
  fi
}

################################################################################
# 2. CHECK/INSTALL GUM (used for fancy UI)
################################################################################
install_gum_if_needed() {
  if command -v gum &>/dev/null; then
    echo "[INFO] Gum is already installed. Skipping..."
  else
    echo "[INFO] Gum not found. Installing via Homebrew..."
    brew tap charmbracelet/tap
    brew install gum
    echo "[INFO] Gum installation complete."
  fi
}

################################################################################
# 3. RUN MODULES (Once we have Gum)
################################################################################
run_modules() {
  # For example, these could be your modules in a separate directory, each with
  # its own script to do one “setup” task.
  local MODULES=(
    "01_xcode.sh:Install Xcode CLI Tools"
    "02_git.sh:Set Up Git (Name & Email)"
    "03_ssh.sh:Set Up SSH"
    "04_brew_tools.sh:Install Brew CLI Tools"
    "05_brew_casks.sh:Install Brew Cask Apps"
    "06_fish.sh:Set Up Fish Shell & Plugins"
    "07_macos_settings.sh:Apply macOS Settings"
  )

  # Present an introduction using Gum
  gum style --border normal --margin "1" --padding "1 2" --border-foreground 212 \
    "Welcome to the Mac Setup Orchestrator!"

  gum style --margin "1" --foreground 99 \
    "We'll run each module script in 'modules/' one by one.\n" \
    "For each step, you'll have the option to confirm or skip."

  if ! gum confirm "Ready to proceed?"; then
    gum style --foreground 214 "Setup canceled by user."
    exit 0
  fi

  # Run through each module, prompting the user to run/skip
  for ENTRY in "${MODULES[@]}"; do
    # Each entry is in the format "filename.sh:Description"
    IFS=":" read -r SCRIPT_FILE DESCRIPTION <<< "$ENTRY"

    local SCRIPT_PATH="./modules/${SCRIPT_FILE}"

    # Check if module script exists
    if [[ ! -f "$SCRIPT_PATH" ]]; then
      gum style --foreground 196 "Script not found: $SCRIPT_PATH"
      continue
    fi

    # Ask user if they want to run the module
    gum style --border normal --margin "1" --padding "1 2" --border-foreground 212 \
      "Module: ${DESCRIPTION}"

    if gum confirm "Run '${DESCRIPTION}'?"; then
      # Show spinner while the script runs
      gum spin --spinner line --title "Running ${SCRIPT_FILE}..." -- bash "$SCRIPT_PATH"
      gum style --foreground 10 "Completed: ${DESCRIPTION}"
    else
      gum style --foreground 214 "Skipped: ${DESCRIPTION}"
    fi
    echo
  done

  # Wrap up
  gum style --border normal --margin "1" --padding "1 2" --border-foreground 10 \
    "All modules have been processed. Setup is complete!"
}

################################################################################
# MAIN
################################################################################
install_homebrew_if_needed
install_gum_if_needed

# Now that we have Gum installed, let's show the fancy UI for module orchestration.
run_modules

exit 0
