#!/bin/bash
# ~/.config/hypr/smart-move.sh
# Usage: smart-move.sh <hypr_direction> <key_for_terminal>
# Examples:
#   smart-move.sh l "CTRL h"    (move left)
#   smart-move.sh d "CTRL j"    (move down)
direction="$1"
key="$2"
window_class=$(hyprctl activewindow -j | jq -r '.class')
if [ "$window_class" = "com.mitchellh.ghostty" ]; then
    # Forward the key to Ghostty → tmux will handle it
    hyprctl dispatch pass class:com.mitchellh.ghostty
else
    hyprctl dispatch movefocus "$direction"
fi
