#!/bin/bash

base=~/.dotfiles

function link {
    src=$base/$1
    dst=`echo "$src" | sed "s/.*\///"` # extract just the filename
    dst=~/.${dst%%.symlink}

    if [ -f $dst ] && ! [ -L $dst ]; then
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
    link system/xterm-256color.ti.symlink
    link tmux/tmux.symlink
    link tmux/tmux.conf.symlink
    link vim/vim.symlink
    link vim/vimrc.symlink
    link zsh/zshrc.symlink

    mkdir -p ~/.config/nvim
    ln -sFv ~/.vimrc ~/.config/nvim/init.vim
    ln -sFv ~/.vim/autoload ~/.config/nvim
    ln -sFv ~/.vim/ftplugin ~/.config/nvim

    touch ~/.simplenoterc
}

env_setup
