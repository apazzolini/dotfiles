#!/bin/bash

SESSION=work

# Attach to the session if it already exists
tmux has-session -t $SESSION
if [ $? -eq 0 ]; then
  tmux -2 attach -t $SESSION
  exit 0;
fi

# Create a new detached session...
tmux -u -2 new-session -d -s $SESSION

next_session=0
spawn_window () {
  tmux new-window -t $SESSION:$next_session -c $2 -k -n $1
  ((next_session++))
}

spawn_window dotfiles ~/.dotfiles
spawn_window server ~/Work/swt/andre/1

tmux select-window -t $SESSION:0
tmux -2 attach -t $SESSION
