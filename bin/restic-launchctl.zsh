#!/bin/zsh

echo "Last run: $(date)" > /var/log/restic/restic
source /Users/andre/.dotfiles/bin/restic.zsh
restic-backup
restic-prune
