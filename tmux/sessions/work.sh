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
  tmux new-window -t $SESSION:$next_session -c "$2" -k -n "$1"
  ((next_session++))
}

spawn_window "dotfiles" ~/.dotfiles
# spawn_window "docker" ~/work/docker
spawn_window "server (react)" ~/work/server
# spawn_window "server (2)" ~/Work/swt/andre/2
# spawn_window "server (3)" ~/Work/swt/andre/3
# spawn_window "server (4)" ~/Work/swt/andre/4
# spawn_window "server (develop)" ~/Work/swt/develop
# spawn_window "server (review)" ~/Work/swt/andre/review

tmux select-window -t $SESSION:0
tmux -2 attach -t $SESSION
