#!/bin/bash
/usr/libexec/PlistBuddy -c 'Add :LSUIElement bool true' /Applications/iTerm.app/Contents/Info.plist
/usr/libexec/PlistBuddy -c 'Add :LSUIElement bool true' /Applications/iTermNotes.app/Contents/Info.plist
