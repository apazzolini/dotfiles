#!/bin/bash

brew install z
brew install starship
brew install coreutils
brew install diff-so-fancy
brew install dnsmasq
brew install fzf
brew install git
brew install htop
brew install python
brew install reattach-to-user-namespace
brew install ripgrep
brew install tmux
brew install zsh-autosuggestions
brew install wget

# Python 2 is no longer in homebrew
cd /tmp
wget https://raw.githubusercontent.com/Homebrew/homebrew-core/86a44a0a552c673a05f11018459c9f5faae3becc/Formula/python@2.rb
brew install python@2.rb
rm python@2.rb
cd -

#brew install --HEAD neovim
brew install neovim

sudo gem install neovim
npm i -g neovim
python2 -m pip install --user --upgrade pynvim
python3 -m pip install --user --upgrade pynvim
