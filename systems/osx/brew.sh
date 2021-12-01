#!/bin/bash

brew analytics off

brew install starship
brew install coreutils
brew install diff-so-fancy
brew install dnsmasq
brew install fzf
brew install git
brew install git-delta
brew install htop
brew install reattach-to-user-namespace
brew install ripgrep
brew install tmux
brew install zsh-autosuggestions
brew install wget
brew install qlstephen qlmarkdown quicklook-json qlimagesize
brew install --HEAD luajit
brew install efm-langserver
brew install gawk

# Neovim Deps instead of brew install --HEAD neovim
brew install ninja libtool automake cmake pkg-config gettext curl
# Commands to build neovim directly from source
# git pull
# make clean
# sudo make distclean
# make CMAKE_BUILD_TYPE=Release -j4
# sudo make install


brew install yt-dlp/taps/yt-dlp

# brew install python
# # Python 2 is no longer in homebrew
# cd /tmp
# wget https://raw.githubusercontent.com/Homebrew/homebrew-core/86a44a0a552c673a05f11018459c9f5faae3becc/Formula/python@2.rb
# brew install python@2.rb
# rm python@2.rb
# cd -
# sudo gem install neovim
# npm i -g neovim
# python2 -m pip install --user --upgrade pynvim
# python3 -m pip install --user --upgrade pynvim
