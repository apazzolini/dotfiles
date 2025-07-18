#!/bin/bash

set -o errexit
set -o errtrace
set -o nounset
set -o pipefail

cd ~/.dotfiles
./link.sh

sudo chown -R andre /usr/local/

sudo pacman -S --noconfirm zsh
sudo chsh andre -s /usr/bin/zsh

if [[ "$LANG" != "en_US.UTF-8" ]]; then
  sudo sed -i 's/^#en_US.UTF-8 UTF-8/en_US.UTF-8 UTF-8/' /etc/locale.gen
  sudo locale-gen
  sudo localectl set-locale LANG=en_US.UTF-8
fi

sudo pacman -S --noconfirm base-devel cmake python go
sudo pacman -S --noconfirm ripgrep fzf htop tmux neovim git-delta unzip wget fd starship lazygit

# Node
curl -fsSL https://raw.githubusercontent.com/tj/n/master/bin/n | bash -s lts
npm install -g n

# Rust
# curl --proto '=https' --tlsv1.2 -sSf https://sh.rustup.rs | sh

# Go
go install golang.org/x/tools/cmd/goimports@latest

# docker
sudo pacman -S --noconfirm docker
sudo systemctl start docker.service
sudo systemctl enable docker.service
sudo usermod -aG docker $USER
