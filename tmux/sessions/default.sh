#!/bin/bash

if [[ "$TERM_PROGRAM" == "iTerm.app" ]]; then
  return;
fi;

if [[ "$(hostname)" = "andrevm" ]]; then
  source ~/.dotfiles/tmux/sessions/work.sh
  return;
fi

SESSION=default

# Attach to the session if it already exists
tmux has-session -t $SESSION 2&>/dev/null
if [ $? -eq 0 ]; then
  tmux -2 attach -t $SESSION
  return;
fi

if [[ "$(hostname)" = "linode" ]]; then
  tmux -u -2 new-session -d -s $SESSION -c /apps
  tmux -2 attach -t $SESSION
elif [[ "$(hostname)" = "andrembw" ]]; then
  return;
else
  tmux -u -2 new-session -d -s $SESSION
  tmux -2 attach -t $SESSION
fi
