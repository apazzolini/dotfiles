#!/bin/bash

command -v tmux >/dev/null 2>&1 || { printf "Cockpit requires tmux but it is not installed.
Please check http://cockpit.27ae60.com/help.html for more information.
Aborting." >&2; exit 1; }

SESSION=work

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

tmux new-window -t $SESSION:0 -k -n dotfiles
tmux send-keys -t ${window}.1 'cd ~/.dotfiles' Enter

next_session=1
spawn_window () {
    tmux new-window -t $SESSION:$next_session -k -n $1
    tmux select-pane -t:.1
    tmux send-keys -t ${window}.1 "cd $2" Enter
    ((next_session++))
}

tmux new-window -t $SESSION:$next_session -k -n shell
((next_session++))
tmux split-window -v -p 70
tmux select-pane -t 1
tmux split-window -h -p 50
tmux select-pane -t:.3
tmux send-keys -t ${window}.1 "cd ~/Work/Float/dws/sites/floatjs/web" Enter
tmux send-keys -t ${window}.2 "cd ~/Work/Float/dws/sites/floatjs/helpers" Enter
tmux send-keys -t ${window}.3 "cd ~/Work/Float/dws/docker-compose" Enter

spawn_window "web" "~/Work/Float/dws/sites/floatjs/web"
# spawn_window "helpers" "~/Work/Float/dws/sites/floatjs/float-helpers"
# spawn_window "search" "~/Work/Float/ws/float-search"
# spawn_window "api3" "~/Work/Float/dws/sites/api3"
# spawn_window "float" "~/Work/Float/dws/sites/float"


# all done. select starting window and get to work
tmux select-window -t $SESSION:0
tmux -2 attach -t $SESSION
