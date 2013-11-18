#! /bin/bash
echo -n "Drag and drop an image file here then press ‘return’ or press ‘control-c’ to cancel…"
read -e WLPR;
defaults write com.apple.desktop Background "{default = {ImageFilePath='$WLPR'; };}"; killall Dock
