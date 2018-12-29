# Sets reasonable OS X defaults.
#
# The original idea (and a couple settings) were grabbed from:
#   https://github.com/mathiasbynens/dotfiles/blob/master/.osx

# Enable full keyboard access for all controls (e.g. enable Tab in modal dialogs)
defaults write NSGlobalDomain AppleKeyboardUIMode -int 3

# Disable menu bar transparency
defaults write -g AppleEnableMenuBarTransparency -bool false

# Expand save panel by default
defaults write -g NSNavPanelExpandedStateForSaveMode -bool true

# Expand print panel by default
defaults write -g PMPrintingExpandedStateForPrint -bool true

# Disable shadow in screenshots
defaults write com.apple.screencapture disable-shadow -bool true

# Disable press-and-hold for keys in favor of key repeat
defaults write -g ApplePressAndHoldEnabled -bool false

# Disable auto-correct
defaults write NSGlobalDomain NSAutomaticSpellingCorrectionEnabled -bool false

# Disable window animations
defaults write NSGlobalDomain NSAutomaticWindowAnimationsEnabled -bool false

# Avoid creating .DS_Store files on network volumes
defaults write com.apple.desktopservices DSDontWriteNetworkStores -bool true

# Show the ~/Library folder
chflags nohidden ~/Library

# Kill affected applications
# for app in Safari Finder Dock Mail; do killall "$app"; done

# Fix for the ancient UTF-8 bug in QuickLook (http://mths.be/bbo)
# echo "0x08000100:0" > ~/.CFUserTextEncoding

# Disable sleepimage file
# sudo pmset -a hibernatemode 0

# Set the personal global git ignore file
# git config --global core.excludesfile '~/.cvsignore'

# Grab fuck-you
# npm install -g fuck-you

# Disable Captive Network Assistant Popup
# sudo mv Captive\ Network\ Assistant.app Captive\ Network\ Assistant.app.bak
