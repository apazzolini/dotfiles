#!/bin/bash

base=~/.dotfiles

function link {
  src=$base/$1
  dst=$2
  ln -sfv "$src" "$dst"
}


function env_setup {
  #git
  link git/.gitconfig ~/
  link git/.githelpers ~/
  link git/.gitignore ~/

  # neovim
  mkdir -p ~/.config
  mkdir -p ~/.local/share/nvim
  link nvim ~/.config/nvim
  link nvim/plugged ~/.local/share/nvim/plugged

  # tmux
  link tmux/.tmux.conf ~/

  # zsh
  link zsh/.zshrc ~/
  link zsh/starship.toml ~/.config
}

env_setup

#link docker/docker.symlink

# coc-settings.json lives in a special place
#mkdir -p ~/.config
#ln -sFv "$base"/vim/coc-settings.json ~/.config/nvim
