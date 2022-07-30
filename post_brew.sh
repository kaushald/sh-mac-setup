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

gum spin --spinner monkey --title "Deleting existing SSH keys..." -- rm -rf ~/.ssh/

gum spin --spinner monkey --title "Creating a new SSH key..." -- ssh-keygen -t ed25519 -C "$EMAIL" -f ~/.ssh/id_ed25519 -q -P ""

gum spin --spinner monkey --title "Loading SSH key..." -- eval "$(ssh-agent -s)"

gum spin --spinner monkey --title "Creating file..." -- touch ~/.ssh/config

gum spin --spinner monkey --title "Updating file..." -- echo -e "Host *\n  AddKeysToAgent yes\n  UseKeychain yes\n  IdentityFile ~/.ssh/id_ed25519" >> ~/.ssh/config

gum spin --spinner monkey --title "Adding key..." -- ssh-add -K ~/.ssh/id_ed25519

gum spin --spinner monkey --title "Copying key..." -- pbcopy < ~/.ssh/id_ed25519.pub

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

echo "Git config"

git config --global user.name "$NAME"
git config --global user.email "$EMAIL"

#############################################################################################
# BREW
#############################################################################################

gum style --border normal --margin "1" --padding "1 2" --border-foreground 212 "Starting $(gum style --foreground 212 'BREW Installs')."

for TOOL in fish gh exa gradle sqlite fzf k9s pipx fd kubernetes-cli bat
do
    gum spin -s monkey --title " Installing $TOOL..." -- brew install $TOOL
    echo -e "\n\n :pager: Installed $TOOL \n\n" | gum format -t emoji
done

#############################################################################################
# CASKS
#############################################################################################

gum style --border normal --margin "1" --padding "1 2" --border-foreground 212 "Staring $(gum style --foreground 212 'CASKS Installs')."


#############################################################################################
# FISH
#############################################################################################

gum style --border normal --margin "1" --padding "1 2" --border-foreground 212 "Staring $(gum style --foreground 212 'FISH Setup')."

gum spin -s monkey --title " Installing fisher..." -- curl -sL https://git.io/fisher | source && fisher install jorgebucaran/fisher
echo -e "\n\n :pager: Installed fisher \n\n" | gum format -t emoji


gum spin -s monkey --title " Installing fisher..." -- fish_add_path /opt/homebrew/bin
echo -e "\n\n :computer: Added brew to fish path \n\n" | gum format -t emoji


echo -e "\n\n :computer: Switch to fish and install plugins :computer:" | gum format -t emoji
gum style --border normal --margin "1" --padding "1 2" --border-foreground 212 "$(gum style --foreground 212 "\
"'fisher install jorgebucaran/nvm.fish'"\
" 'fisher install IlanCosman/tide@v5'"\
" 'fisher install PatrickF1/fzf.fish'"\
" 'fzf_configure_bindings --help'"\
" 'fisher install andreiborisov/sponge'"\
" 'fisher install jethrokuan/z'"\
" 'pipx install dunk'"\
" 'fisher install jorgebucaran/autopair.fish')"

