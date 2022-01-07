#!/bin/bash

SESSION=default

# Attach to the session if it already exists
tmux has-session -t $SESSION
if [ $? -eq 0 ]; then
  tmux -2 attach -t $SESSION
  exit 0;
fi

if [[ `hostname` = "linode" ]]; then
  tmux -u -2 new-session -d -s $SESSION -c /apps
else
  tmux -u -2 new-session -d -s $SESSION
fi

tmux -2 attach -t $SESSION
