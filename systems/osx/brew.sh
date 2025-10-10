#!/bin/bash

if ! command -v brew > /dev/null 2>&1; then
    echo "Installing brew..."
    /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
    exit 1;
fi

brew analytics off

brew install lazygit
brew install starship
brew install coreutils
brew install fzf
brew install git
brew install git-delta
brew install htop
brew install ripgrep
brew install tmux
brew install zsh-autosuggestions
brew install wget
# brew install --cask --no-quarantine middleclick
brew install go
brew install sqlite
# brew install ffmpeg
brew install neovim
brew install make cmake gettext curl
brew install hammerspoon
brew install karabiner-elements
brew install alfred
# brew install fliqlo
brew install iterm2
brew install fd
brew install spotify
brew install dua-cli
brew install ghostty
brew install istat-menus
brew install firefox
brew install discord
# brew install sanesidebuttons
