#!/bin/bash

command -v tmux >/dev/null 2>&1 || { printf "Cockpit requires tmux but it is not installed.
Please check http://cockpit.27ae60.com/help.html for more information.
Aborting." >&2; exit 1; }

SESSION=dre

# if the session is already running, just attach to it.
tmux has-session -t $SESSION
if [ $? -eq 0 ]; then
  echo "Session $SESSION already exists. Attaching."
  tmux -2 attach -t $SESSION
  exit 0;
fi

# create a new session, named $SESSION, and detach from it
tmux -u -2 new-session -d -s $SESSION -x 393 -y 95

# Now populate the session with the windows you use every day
tmux set-option -g base-index 0
tmux set-window-option -t $SESSION -g automatic-rename off
tmux set-window-option -t $SESSION set-titles on
tmux set-window-option -t $SESSION status on
tmux set-window-option -t $SESSION status-position top
tmux set-window-option -g pane-base-index 1

tmux new-window -t $SESSION:1 -k -n dotfiles
tmux send-keys -t ${window}.1 'cd ~/.dotfiles' Enter

next_session=1
spawn_window () {
    tmux new-window -t $SESSION:$next_session -k -n $1
    tmux split-window -h -l 110
    tmux select-pane -t:.1
    tmux send-keys -t ${window}.1 "cd $2" Enter
    tmux send-keys -t ${window}.2 "cd $2" Enter
    ((next_session++))
}

spawn_window "pubg.sh-api" "~/GitHub/pubg.sh-api"
spawn_window "pubg.sh-client" "~/GitHub/pubg.sh-client"

# all done. select starting window and get to work
tmux select-window -t $SESSION:0
tmux -2 attach -t $SESSION
