#!/usr/bin/env bash
################################################################################
# 04_brew_tools.sh
#
# Installs a list of brew CLI tools if not already installed.
################################################################################

set -euo pipefail
trap 'echo -e "\n[ERROR] in 04_brew_tools.sh at line $LINENO. Exiting..." >&2' ERR

if ! command -v gum &>/dev/null; then
  echo "[ERROR] gum not found. Please run through the orchestrator."
  exit 1
fi

TOOLS=(
  bat
  eza
  fd
  ffmpeg
  ffmpegthumbnailer
  fish
  flyctl
  font-symbols-only-nerd-font
  fzf
  gh
  gradle
  imagemagick
  jq
  k9s
  kubernetes-cli
  lazygit
  nushell
  nvim
  pipx
  poppler
  ripgrep
  sevenzip
  sqlite
  tlrc
  yazi
  zoxide
)

################################################################################
# 1. Confirm user wants to proceed with bulk install
################################################################################
gum style --border normal --margin "1" --padding "1 2" --border-foreground 212 \
  "Installing Brew CLI tools"

gum style --margin "1" --foreground 99 \
  "We will install the following tools:\n${TOOLS[*]}"

if ! gum confirm "Proceed with brew install for these tools?"; then
  gum style --foreground 214 "Skipped installing Brew CLI tools."
  exit 0
fi

################################################################################
# 2. Loop over each tool and install if missing
################################################################################
for TOOL in "${TOOLS[@]}"; do
  if brew list --formula | grep -q "^${TOOL}\$"; then
    gum style --foreground "10" "Already installed: $TOOL. Skipping..."
  else
    gum spin --spinner line --title "brew install $TOOL..." -- \
      brew install "$TOOL"
    gum style --foreground "10" "Installed: $TOOL"
  fi
done

exit 0
