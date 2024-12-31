#!/usr/bin/env bash
################################################################################
# all-in-one.sh
#
# A single script that handles:
#   1) Installing Homebrew
#   2) Installing Gum
#   3) Running each setup step (Xcode, Git, SSH, Brew Tools, Casks, Fish, macOS).
#
# Idempotency, Logging, and a Gum-based UI are included.
################################################################################

# 1. Strict error handling
set -euo pipefail
trap 'echo -e "\n[ERROR] at line $LINENO. Exiting..." >&2' ERR

# 2. (OPTIONAL) Logging
# Uncomment the lines below to capture everything to a log file as well.
LOG_FILE="${HOME}/mac_setup.log"
exec > >(tee -a "${LOG_FILE}") 2>&1

# 3. Clean up the dock

# Remove all pinned (persistent) apps
defaults delete com.apple.dock persistent-apps 2>/dev/null

# Remove any persistent others (like folders or minimized windows)
defaults delete com.apple.dock persistent-others 2>/dev/null

# 1. Set Dock size to 10% of the default
# The default icon size is typically 64 pixels (varies by macOS version).
# So, 10% of that is roughly 6-7 pixels.
# That is extremely small, so let's pick 16 pixels (which is about 25%).
# Feel free to adjust to your liking.
defaults write com.apple.dock tilesize -int 16

# 2. Disable the "Show suggested and recent apps in Dock"
defaults write com.apple.dock show-recents -bool false

# Restart the Dock so changes take effect
killall Dock

################################################################################
# STEP 0: Basic Bootstrap - Homebrew & Gum
################################################################################
install_homebrew_if_needed() {
  if command -v brew &>/dev/null; then
    echo "[INFO] Homebrew is already installed. Skipping..."
  else
    echo "[INFO] Homebrew not found. Installing..."
    /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"

    # Initialize Brew in the user's environment
    if [[ "$(uname -m)" == "arm64" ]]; then
      echo 'eval "$(/opt/homebrew/bin/brew shellenv)"' >>"${HOME}/.zprofile"
      eval "$(/opt/homebrew/bin/brew shellenv)"
    else
      echo 'eval "$(/usr/local/bin/brew shellenv)"' >>"${HOME}/.zprofile"
      eval "$(/usr/local/bin/brew shellenv)"
    fi

    echo "[INFO] Homebrew installation complete."
  fi
}

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
# STEP 1: Xcode CLI Tools
################################################################################
step_xcode() {
  # Check if Xcode CLI Tools are installed
  if xcode-select -p &>/dev/null; then
    gum style --border normal --margin "1" --padding "1 2" --border-foreground "10" \
      "Xcode Command Line Tools are already installed. Skipping..."
    return 0
  fi

  gum style --border normal --margin "1" --padding "1 2" --border-foreground 212 \
    "Xcode CLI Tools not found."

  gum style --margin "1" --foreground 99 \
    "We'll run 'xcode-select --install' to initiate installation.\n" \
    "A GUI popup will appear; follow instructions."

  if gum confirm "Proceed with Xcode CLI Tools installation?"; then
    gum spin --spinner line --title "Installing Xcode CLI Tools..." -- \
      xcode-select --install

    gum style --foreground "10" "Installation triggered. Please follow popups."
    # Wait a bit so user can respond to any popup
    sleep 5

    if xcode-select -p &>/dev/null; then
      gum style --foreground "10" "Xcode CLI Tools are now installed!"
    else
      gum style --foreground "214" "Installation not confirmed yet. You may need to rerun."
    fi
  else
    gum style --foreground "214" "Skipped Xcode CLI Tools installation."
  fi
}

################################################################################
# STEP 2: Git Config
################################################################################
step_git() {
  local CURRENT_NAME CURRENT_EMAIL
  CURRENT_NAME=$(git config --global user.name || true)
  CURRENT_EMAIL=$(git config --global user.email || true)

  # If already set, skip
  if [[ -n "$CURRENT_NAME" && -n "$CURRENT_EMAIL" ]]; then
    gum style --border normal --margin "1" --padding "1 2" --border-foreground "10" \
      "Git global config already set:\nName: $CURRENT_NAME\nEmail: $CURRENT_EMAIL\nSkipping..."
    return 0
  fi

  gum style --border normal --margin "1" --padding "1 2" --border-foreground 212 \
    "Set up Git global config"

  local NAME EMAIL
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
}

################################################################################
# STEP 3: SSH Keys
################################################################################
step_ssh() {
  local SSH_KEY="${HOME}/.ssh/id_ed25519"

  if [[ -f "$SSH_KEY" ]]; then
    gum style --border normal --margin "1" --padding "1 2" --border-foreground "10" \
      "An SSH key already exists at $SSH_KEY. Skipping generation..."
    return 0
  fi

  gum style --border normal --margin "1" --padding "1 2" --border-foreground 212 \
    "No ed25519 SSH key found."

  gum style --margin "1" --foreground 99 \
    "We'll create a new ed25519 key in ~/.ssh/id_ed25519."

  if gum confirm "Generate a new SSH key now?"; then
    gum spin --spinner line --title "Generating SSH key..." -- \
      ssh-keygen -t ed25519 -C "github-$(date +%Y%m%d)" -f "$SSH_KEY" -N ""

    eval "$(ssh-agent -s)"
    ssh-add -K "$SSH_KEY"

    pbcopy <"$SSH_KEY.pub"
    gum style --foreground "10" "SSH key generated and copied to clipboard!"
    gum style --margin "1" --foreground 99 \
      "Add this public key to your GitHub account:\nhttps://github.com/settings/keys"
  else
    gum style --foreground "214" "Skipped SSH key generation."
  fi
}

################################################################################
# STEP 4: Brew CLI Tools
################################################################################
step_brew_tools() {
  local TOOLS=(
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
    ghostty
    gradle
    imagemagick
    jq
    k9s
    kubernetes-cli
    lazygit
    pipx
    poppler
    ripgrep
    sevenzip
    sqlite
    yazi
    zoxide
  )

  gum style --border normal --margin "1" --padding "1 2" --border-foreground 212 \
    "Install Brew CLI tools"

  gum style --margin "1" --foreground 99 \
    "Tools to install:\n${TOOLS[*]}"

  if ! gum confirm "Proceed with brew install for these tools?"; then
    gum style --foreground 214 "Skipped installing Brew CLI tools."
    return 0
  fi

  # brew update first?
  gum spin --spinner line --title "brew update..." -- brew update

  for TOOL in "${TOOLS[@]}"; do
    if brew list --formula | grep -q "^${TOOL}\$"; then
      gum style --foreground "10" "Already installed: $TOOL. Skipping..."
    else
      gum spin --spinner line --title "brew install $TOOL..." -- brew install "$TOOL"
      gum style --foreground "10" "Installed: $TOOL"
    fi
  done
}

################################################################################
# STEP 5: Brew Casks
################################################################################
step_brew_casks() {
  local CASKS=(
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
    discord
    docker
    elgato-stream-deck
    firefox
    gitkraken
    google-chrome
    google-cloud-sdk
    handbrake
    iterm2
    jetbrains-toolbox
    kitty
    lens
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

  gum style --border normal --margin "1" --padding "1 2" --border-foreground 212 \
    "Install Brew Cask Apps"

  gum style --margin "1" --foreground 99 \
    "Cask apps to install:\n${CASKS[*]}"

  if ! gum confirm "Proceed with installing these cask apps?"; then
    gum style --foreground 214 "Skipped installing Brew cask apps."
    return 0
  fi

  for CASK in "${CASKS[@]}"; do
    if brew list --cask | grep -q "^${CASK}\$"; then
      gum style --foreground "10" "Already installed: $CASK. Skipping..."
    else
      brew install --cask "$CASK"
    fi
  done
}

################################################################################
# STEP 6: Fish Shell Setup
################################################################################
step_fish() {
  # Check if fish is installed
  if ! command -v fish &>/dev/null; then
    gum style --foreground 196 "Fish is not installed. Please ensure it was installed in a previous step."
    gum style --foreground 214 "Skipping Fish setup."
    return 0
  fi

  # 1) Make fish the default shell
  local CURRENT_SHELL
  CURRENT_SHELL=$(dscl . -read /Users/"$(whoami)" UserShell | awk '{print $2}')

  if [[ "$CURRENT_SHELL" == *"/fish" ]]; then
    gum style --foreground "10" "Fish is already the default shell. Skipping that part..."
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

  # 2) Ensure Homebrew bin is in fish path
  local FISH_HOMEBREW_PATH
  if [[ "$(uname -m)" == "arm64" ]]; then
    FISH_HOMEBREW_PATH="/opt/homebrew/bin"
  else
    FISH_HOMEBREW_PATH="/usr/local/bin"
  fi

  # Add to config.fish if not present
  mkdir -p "${HOME}/.config/fish"
  if ! grep -Fq "$FISH_HOMEBREW_PATH" "${HOME}/.config/fish/config.fish" 2>/dev/null; then
    echo "fish_add_path $FISH_HOMEBREW_PATH" >>"${HOME}/.config/fish/config.fish"
    gum style --foreground "10" "Added: fish_add_path $FISH_HOMEBREW_PATH to config.fish"
  else
    gum style --foreground "10" "Path $FISH_HOMEBREW_PATH already in config.fish. Skipping..."
  fi

  # 3) Install fish plugins
  gum style --border normal --margin "1" --padding "1 2" --border-foreground 212 \
    "Install Fish Plugins"

  gum style --margin "1" --foreground 99 \
    "We'll install 'fisher' plugin manager and some common plugins."

  if gum confirm "Proceed with Fish plugin installation?"; then
    fish -c "curl -sL https://git.io/fisher | source && fisher update"
    fish -c "fisher install jorgebucaran/fisher"
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
}

################################################################################
# STEP 7: macOS Settings
################################################################################
step_macos_settings() {
  gum style --border normal --margin "1" --padding "1 2" --border-foreground 212 \
    "Apply macOS Settings"

  gum style --margin "1" --foreground 99 \
    "We'll apply various defaults write commands to configure macOS preferences."

  if ! gum confirm "Proceed with applying macOS settings?"; then
    gum style --foreground 214 "Skipped macOS settings."
    return 0
  fi

  gum spin --spinner line --title "Applying macOS settings..." -- sleep 1

  # Example preferences
  defaults write NSGlobalDomain NSNavPanelExpandedStateForSaveMode -bool true
  defaults write NSGlobalDomain PMPrintingExpandedStateForPrint -bool true
  defaults write NSGlobalDomain PMPrintingExpandedStateForPrint2 -bool true
  defaults write NSGlobalDomain NSDocumentSaveNewDocumentsToCloud -bool false
  defaults write com.apple.SoftwareUpdate ScheduleFrequency -int 1
  defaults write NSGlobalDomain AppleShowAllExtensions -bool true
  defaults write com.apple.finder FXPreferredViewStyle Clmv
  defaults write com.apple.desktopservices DSDontWriteNetworkStores -bool true
  defaults write com.apple.dock tilesize -int 36
  defaults write com.apple.dock expose-animation-duration -float 0.1
  defaults write com.apple.dock expose-group-by-app -bool true
  defaults write com.apple.dock mru-spaces -bool false

  killall Finder || true
  killall Dock || true

  gum style --foreground "10" "macOS settings applied!"
}

################################################################################
# MAIN SEQUENCE
################################################################################

# 1. Install Homebrew & Gum
install_homebrew_if_needed
install_gum_if_needed

# 2. Now that Gum is installed, let's use it for the fancy UI steps
gum style --border normal --margin "1" --padding "1 2" --border-foreground 212 \
  "Welcome to the One-Giant-Setup Script!"

gum style --margin "1" --foreground 99 \
  "We'll go through each setup step in sequence.\nYou can run or skip each step."

if ! gum confirm "Ready to proceed?"; then
  gum style --foreground 214 "Setup canceled by user."
  exit 0
fi

# 3. Define steps and descriptions (function_name:Description)
declare -a STEPS=(
  "step_xcode:Install Xcode CLI Tools"
  "step_git:Set Up Git (Name & Email)"
  "step_ssh:Set Up SSH Keys"
  "step_brew_tools:Install Brew CLI Tools"
  "step_brew_casks:Install Brew Cask Apps"
  "step_fish:Set Up Fish Shell & Plugins"
  "step_macos_settings:Apply macOS Settings"
)

# 4. Run them in order
for STEP_INFO in "${STEPS[@]}"; do
  IFS=":" read -r STEP_FUNC DESCRIPTION <<<"$STEP_INFO"

  gum style --border normal --margin "1" --padding "1 2" --border-foreground 212 \
    "Next Step: ${DESCRIPTION}"

  if gum confirm "Run '${DESCRIPTION}'?"; then
    # Show spinner while the function runs
    gum spin --spinner line --title "Running ${STEP_FUNC}..." -- \
      bash -c "${STEP_FUNC}"
    gum style --foreground "10" "Completed: ${DESCRIPTION}"
  else
    gum style --foreground 214 "Skipped: ${DESCRIPTION}"
  fi
  echo
done

# 5. Outro
gum style --border normal --margin "1" --padding "1 2" --border-foreground 10 \
  "All steps have been processed."

gum style --margin "1" --foreground 99 \
  "If everything went well, enjoy your new Mac setup!\n" \
  "You can re-run this script any time to skip or re-run steps."

exit 0
