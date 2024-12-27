#!/usr/bin/env bash
################################################################################
# 03_ssh.sh
#
# Checks if an SSH key (ed25519) exists, and if not, prompts to generate one.
################################################################################

set -euo pipefail
trap 'echo -e "\n[ERROR] in 03_ssh.sh at line $LINENO. Exiting..." >&2' ERR

if ! command -v gum &>/dev/null; then
  echo "[ERROR] gum not found. Please run through the orchestrator."
  exit 1
fi

SSH_KEY="${HOME}/.ssh/id_ed25519"

################################################################################
# 1. Check if SSH key already exists
################################################################################
if [[ -f "$SSH_KEY" ]]; then
  gum style --border normal --margin "1" --padding "1 2" --border-foreground "10" \
    "An SSH key already exists at $SSH_KEY\nSkipping generation..."
  exit 0
fi

################################################################################
# 2. Prompt to generate
################################################################################
gum style --border normal --margin "1" --padding "1 2" --border-foreground 212 \
  "No SSH key found."

gum style --margin "1" --foreground 99 \
  "We'll create a new ed25519 key in ~/.ssh/id_ed25519."

if gum confirm "Generate a new SSH key now?"; then
  gum spin --spinner line --title "Generating ed25519 SSH key..." -- \
    ssh-keygen -t ed25519 -C "github-$(date +%Y%m%d)" -f "$SSH_KEY" -N ""

  eval "$(ssh-agent -s)"
  ssh-add -K "$SSH_KEY"

  # Copy to clipboard
  pbcopy <"$SSH_KEY.pub"

  gum style --foreground "10" "SSH key generated and copied to clipboard!"
  gum style --margin "1" --foreground 99 \
    "Add this public key to your GitHub account at:\nhttps://github.com/settings/keys"
else
  gum style --foreground "214" "Skipped SSH key generation."
fi

exit 0
