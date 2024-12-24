#!/bin/zsh

echo "Last run: $(date)" > /var/log/borg/borg
source /Users/andre/.dotfiles/bin/borg.zsh
borg-backup
borg-prune
