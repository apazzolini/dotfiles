#!/bin/bash

function link {
  src="$HOME/.dotfiles/$1"
  dst="$2"
  ln -sfv "$src" "$dst"
}

function env_setup {
  mkdir -p ~/.config

  #git
  link git/gitconfig ~/.gitconfig
  link git/githelpers ~/.githelpers
  link git/gitignore ~/.gitignore
  mkdir -p ~/.config/lazygit
  link git/lazygit/config.yml ~/.config/lazygit/

  # neovim
  mkdir -p ~/.config
  mkdir -p ~/.local/share/nvim
  link nvim ~/.config/

  # tmux
  link tmux/tmux.conf ~/.tmux.conf

  # zsh
  link zsh/zshrc.zsh ~/.zshrc
  link zsh/zprofile.zsh ~/.zprofile
  link zsh/zshenv.zsh ~/.zshenv
  link zsh/starship.toml ~/.config
}

env_setup
