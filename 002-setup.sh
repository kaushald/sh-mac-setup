#!/bin/bash

echo "Brew installing..."
brew update
brew tap charmbracelet/tap && brew install charmbracelet/tap/gum
echo "Installed"
echo "============================================================"

clear 

gum style --border normal --margin "1" --padding "1 2" --border-foreground 212 "Welcome to $(gum style --foreground 212 'Kaos Mac Setup')."
echo -e "Can you tell me a $(gum style --italic --foreground 99 'your full name')?\n"
NAME=$(gum input --placeholder "What is your full name?")

echo -e "Well, it is nice to meet you, $(gum style --foreground 212 "$NAME").\n\n"

gum spin -s pulse --title "Saving name..." -- sleep 2 && clear

echo -e "Can you tell me your $(gum style --italic --foreground 99 'email address')?\n"

EMAIL=$(gum input --placeholder "What is your email?")

echo -e "Will use this email to configure git $(gum style --foreground 212 "$EMAIL").\n\n"

gum spin -s monkey --title "Saving email..." -- sleep 2 && clear

#############################################################################################
# SSH
#############################################################################################

gum style --border normal --margin "1" --padding "1 2" --border-foreground 212 "Starting $(gum style --foreground 212 'SSH Setup')."

rm -rf ~/.ssh/
sh-keygen -t ed25519 -C "$EMAIL" -f ~/.ssh/id_ed25519 -q -P ""
eval "$(ssh-agent -s)"
touch ~/.ssh/config
echo -e "Host *\n  AddKeysToAgent yes\n  UseKeychain yes\n  IdentityFile ~/.ssh/id_ed25519" >> ~/.ssh/config
ssh-add -K ~/.ssh/id_ed25519
pbcopy < ~/.ssh/id_ed25519.pub

echo -e "Copy the key to your clipboard using - $(gum style --foreground 212 "pbcopy < ~/.ssh/id_ed25519.pub")\n\nand then please add this public key to Github - $(gum style --foreground 212 "https://github.com/account/ssh").\n\n"

gum confirm "Are you Done?" && echo "Great! Proceeding..."  && sleep 1 && clear || echo "Too bad! Proceeding..." && sleep 1 && clear

#############################################################################################
# XCODE
#############################################################################################

gum style --border normal --margin "1" --padding "1 2" --border-foreground 212 "Starting $(gum style --foreground 212 'XCODE Setup')."

echo -e "Follow the $(gum style --italic --foreground 99 'prompts')!\n"

xcode-select --install 

gum spin --spinner monkey --title "Waiting..." -- sleep 5

clear

#############################################################################################
# GIT
#############################################################################################

gum style --border normal --margin "1" --padding "1 2" --border-foreground 212 "Starting $(gum style --foreground 212 'GIT Setup')."


git config --global user.name "$NAME"
git config --global user.email "$EMAIL"

clear

#############################################################################################
# BREW
#############################################################################################

gum style --border normal --margin "1" --padding "1 2" --border-foreground 212 "Starting $(gum style --foreground 212 'BREW Installs')."

for TOOL in fish gh exa gradle sqlite fzf k9s pipx fd kubernetes-cli bat flyctl
do
    gum spin -s monkey --title " Installing $TOOL..." -- brew install $TOOL
    echo -e "\n\n :pager: Installed $TOOL \n\n" | gum format -t emoji
done

#############################################################################################
# CASKS
#############################################################################################

gum style --border normal --margin "1" --padding "1 2" --border-foreground 212 "Staring $(gum style --foreground 212 'CASKS Installs')."

for TOOL in 1password beyond-compare docker handbrake microsoft-auto-update microsoft-powerpoint notion royal-tsx telegram whatsapp adobe-creative-cloud brave-browser firefox iterm2 microsoft-edge microsoft-teams obs signal tidal zoom alfred calibre gitkraken jetbrains-toolbox microsoft-excel microsoft-word parallels-toolbox slack visual-studio-code bartender discord google-chrome lens microsoft-outlook mysqlworkbench postman sublime-text vlc
do
    brew install --cask $TOOL
    echo -e "\n\n :pager: Installed $TOOL \n\n" | gum format -t emoji
done

#############################################################################################
# FISH
#############################################################################################

gum style --border normal --margin "1" --padding "1 2" --border-foreground 212 "Staring $(gum style --foreground 212 'FISH Setup')."

sudo echo /opt/homebrew/bin/fish | sudo tee -a /etc/shells
sudo chsh -s /opt/homebrew/bin/fish

echo -e "\n\n :computer: Switch to fish and install plugins :computer:" | gum format -t emoji
gum style --border normal --margin "1" --padding "1 2" --border-foreground 212 "$(gum style --foreground 212 "\
"'curl -sL https://git.io/fisher | source && fisher install jorgebucaran/fisher'"\
" 'chsh -s /opt/homebrew/bin/fish'"\
" 'fish_add_path /opt/homebrew/bin'"\
" 'fisher install jorgebucaran/nvm.fish'"\
" 'fisher install IlanCosman/tide@v5'"\
" 'fisher install PatrickF1/fzf.fish'"\
" 'fzf_configure_bindings --help'"\
" 'fisher install andreiborisov/sponge'"\
" 'fisher install jethrokuan/z'"\
" 'pipx install dunk'"\
" 'fisher install jorgebucaran/autopair.fish')"

#############################################################################################
# CONFIF
#############################################################################################

#"Expanding the save panel by default"
defaults write NSGlobalDomain NSNavPanelExpandedStateForSaveMode -bool true
defaults write NSGlobalDomain PMPrintingExpandedStateForPrint -bool true
defaults write NSGlobalDomain PMPrintingExpandedStateForPrint2 -bool true

#"Saving to disk (not to iCloud) by default"
defaults write NSGlobalDomain NSDocumentSaveNewDocumentsToCloud -bool false

#"Check for software updates daily, not just once per week"
defaults write com.apple.SoftwareUpdate ScheduleFrequency -int 1

#"Enabling subpixel font rendering on non-Apple LCDs"
defaults write NSGlobalDomain AppleFontSmoothing -int 2

#"Showing icons for hard drives, servers, and removable media on the desktop"
defaults write com.apple.finder ShowExternalHardDrivesOnDesktop -bool true

#"Showing all filename extensions in Finder by default"
defaults write NSGlobalDomain AppleShowAllExtensions -bool true

#"Disabling the warning when changing a file extension"
defaults write com.apple.finder FXEnableExtensionChangeWarning -bool false

#"Use column view in all Finder windows by default"
defaults write com.apple.finder FXPreferredViewStyle Clmv

#"Avoiding the creation of .DS_Store files on network volumes"
defaults write com.apple.desktopservices DSDontWriteNetworkStores -bool true

#"Enabling snap-to-grid for icons on the desktop and in other icon views"
/usr/libexec/PlistBuddy -c "Set :DesktopViewSettings:IconViewSettings:arrangeBy grid" ~/Library/Preferences/com.apple.finder.plist
/usr/libexec/PlistBuddy -c "Set :FK_StandardViewSettings:IconViewSettings:arrangeBy grid" ~/Library/Preferences/com.apple.finder.plist
/usr/libexec/PlistBuddy -c "Set :StandardViewSettings:IconViewSettings:arrangeBy grid" ~/Library/Preferences/com.apple.finder.plist

#"Setting the icon size of Dock items to 36 pixels for optimal size/screen-realestate"
defaults write com.apple.dock tilesize -int 36

#"Speeding up Mission Control animations and grouping windows by application"
defaults write com.apple.dock expose-animation-duration -float 0.1
defaults write com.apple.dock "expose-group-by-app" -bool true

# Don’t automatically rearrange Spaces based on most recent use
defaults write com.apple.dock mru-spaces -bool false

gum confirm "Are you Done?" && echo "Great! Proceeding..."  && sleep 1 && clear || echo "Too bad! Proceeding..." && sleep 1 && clear

killall Finder