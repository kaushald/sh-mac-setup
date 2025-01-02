#!/bin/bash

# Remove all pinned (persistent) apps
defaults delete com.apple.dock persistent-apps 2>/dev/null

# Remove any persistent others (like folders or minimized windows)
defaults delete com.apple.dock persistent-others 2>/dev/null

# 1. Set Dock size to 10% of the default
# The default icon size is typically 64 pixels (varies by macOS version).
# So, 10% of that is roughly 6-7 pixels.
# That is extremely small, so let's pick 16 pixels (which is about 25%).
# Feel free to adjust to your liking.
defaults write com.apple.dock tilesize -int 32

# 2. Disable the "Show suggested and recent apps in Dock"
defaults write com.apple.dock show-recents -bool false

# Restart the Dock so changes take effect
killall Dock
