#!/bin/sh

# Check for win32yank.exe executable
if command -v win32yank.exe >/dev/null 2>/dev/null; then
    # The --lf option pastes data unix style. Which is what I almost always want.
    win32yank.exe -o --lf
else
    # Else rely on PowerShell being installed and available.
    powershell.exe Get-Clipboard | tr -d '\r' | sed -z '$ s/\n$//'
fi
