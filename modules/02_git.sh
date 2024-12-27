#!/usr/bin/env bash
################################################################################
# 02_git.sh
#
# Prompts user for Git name/email config if not already set.
################################################################################

set -euo pipefail
trap 'echo -e "\n[ERROR] in 02_git.sh at line $LINENO. Exiting..." >&2' ERR

if ! command -v gum &>/dev/null; then
  echo "[ERROR] gum not found. Please run through the orchestrator."
  exit 1
fi

################################################################################
# 1. Check if Git user.name / user.email are already set
################################################################################
CURRENT_NAME=$(git config --global user.name || true)
CURRENT_EMAIL=$(git config --global user.email || true)

if [[ -n "$CURRENT_NAME" && -n "$CURRENT_EMAIL" ]]; then
  gum style --border normal --margin "1" --padding "1 2" --border-foreground "10" \
    "Git global config already set to:\nName: $CURRENT_NAME\nEmail: $CURRENT_EMAIL\nSkipping..."
  exit 0
fi

################################################################################
# 2. Prompt user for Git name/email
################################################################################
gum style --border normal --margin "1" --padding "1 2" --border-foreground 212 \
  "Set up Git global config"

NAME=$(gum input --placeholder "Full Name" --value "${CURRENT_NAME}")
EMAIL=$(gum input --placeholder "Email Address" --value "${CURRENT_EMAIL}")

gum style --margin "1" "You entered:"
gum style --foreground "212" "Name: $NAME"
gum style --foreground "212" "Email: $EMAIL"

if gum confirm "Use these for Git config?"; then
  git config --global user.name "$NAME"
  git config --global user.email "$EMAIL"
  gum style --foreground "10" "Git config updated!"
else
  gum style --foreground "214" "Skipped updating Git config."
fi

exit 0
