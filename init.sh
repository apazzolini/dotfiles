#!/bin/bash

base=~/.dotfiles

function link {
    src=$base/$1
    dst=`echo "$src" | sed "s/.*\///"` # extract just the filename
    dst=~/.${dst%%.symlink}

    if ([ -f $dst ] || [ -d $dst ]) && ! [ -L $dst ]; then
        echo "$dst exists and is a regular file. Exiting"
        exit 1
    fi

    if [ -e $dst ]; then
        echo "$dst is already a link"
        return
    fi

    echo "$src --> $dst"
    ln -s "$src" "$dst"
}

function env_setup {
    link git/gitconfig.symlink
    link git/githelpers.symlink
    link git/gitignore.symlink
    link vim/vim.symlink
    link vim/vimrc.symlink
    link zsh/zshrc.symlink
    link docker/docker.symlink

    link config/alacritty

    if [ `uname` = 'Darwin' ]
    then
        link tmux/tmux.symlink
        link tmux/tmux.conf.symlink
    fi

    mkdir -p ~/.config/nvim
    ln -sFv ~/.vimrc ~/.config/nvim/init.vim
    ln -sFv ~/.vim/autoload ~/.config/nvim
    ln -sFv ~/.vim/after ~/.config/nvim
    ln -sFv "$base"/vim/coc-settings.json ~/.config/nvim

    mkdir -p ~/.config/alacritty
    ln -sFv "$base"/apps/alacritty.yml ~/.config/alacritty/
}

env_setup
