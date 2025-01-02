#!/bin/bash

echo "Applying new macOS settings..."

# Expanding the save panel by default
defaults write NSGlobalDomain NSNavPanelExpandedStateForSaveMode -bool true
defaults write NSGlobalDomain PMPrintingExpandedStateForPrint -bool true
defaults write NSGlobalDomain PMPrintingExpandedStateForPrint2 -bool true
echo "Save and print panels expanded by default."

# Saving to disk (not iCloud) by default
defaults write NSGlobalDomain NSDocumentSaveNewDocumentsToCloud -bool false
echo "Default save location set to disk."

# Check for software updates daily
defaults write com.apple.SoftwareUpdate ScheduleFrequency -int 1
echo "Software update frequency set to daily."

# Enabling subpixel font rendering on non-Apple LCDs
defaults write NSGlobalDomain AppleFontSmoothing -int 2
echo "Subpixel font rendering enabled."

# Show icons for drives and removable media on desktop
defaults write com.apple.finder ShowExternalHardDrivesOnDesktop -bool true
echo "Drive icons will appear on the desktop."

# Show all filename extensions in Finder
defaults write NSGlobalDomain AppleShowAllExtensions -bool true
echo "Filename extensions will now be visible."

# Disable warning when changing file extensions
defaults write com.apple.finder FXEnableExtensionChangeWarning -bool false
echo "File extension change warning disabled."

# Use column view in Finder by default
defaults write com.apple.finder FXPreferredViewStyle Clmv
echo "Finder default view set to column view."

# Avoid creating .DS_Store files on network volumes
defaults write com.apple.desktopservices DSDontWriteNetworkStores -bool true
echo "DS_Store files will not be created on network volumes."

# Enable snap-to-grid for icons
/usr/libexec/PlistBuddy -c "Set :DesktopViewSettings:IconViewSettings:arrangeBy grid" ~/Library/Preferences/com.apple.finder.plist
/usr/libexec/PlistBuddy -c "Set :FK_StandardViewSettings:IconViewSettings:arrangeBy grid" ~/Library/Preferences/com.apple.finder.plist
/usr/libexec/PlistBuddy -c "Set :StandardViewSettings:IconViewSettings:arrangeBy grid" ~/Library/Preferences/com.apple.finder.plist
echo "Snap-to-grid enabled for icons."

# Set Dock icon size to 36 pixels
defaults write com.apple.dock tilesize -int 36
echo "Dock icon size set to 36 pixels."

# Speed up Mission Control animations and group by app
defaults write com.apple.dock expose-animation-duration -float 0.1
defaults write com.apple.dock expose-group-by-app -bool true
echo "Mission Control animations sped up and windows grouped by app."

# Disable automatic rearranging of Spaces
defaults write com.apple.dock mru-spaces -bool false
echo "Spaces will no longer rearrange automatically."

# Restart affected services
echo "Restarting Finder and Dock to apply changes..."
killall Finder
killall Dock

echo "All settings have been applied successfully!"
