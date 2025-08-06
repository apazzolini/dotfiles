# Manual OS X Setup

These things aren't automated.

- Set hostname
    - 2 places in system settings and sudo scutil --set HostName <name>

- Download From App Store:

    - Mela
    - Command X
    - Hyperduck
    - Dato
    - Windows App

- Download From Elsewhere:

    - Tailscale
    - iStatMenus
    - SaneSideButtons
    - Syncthing
    - Amphetamine
    - Deskflow

- Configure Borg
    - `brew install borgbackup`
    - Add borg-passphrase (kind = secert) to OS X keychain
    - Download borg-repokeys.zip and extract to ~/.config/
    - `ln -s ~/.dotfiles/systems/osx/borg.plist ~/Library/LaunchAgents/borg.plist`
    - `launchctl load ~/Library/LaunchAgents/borg.plist`
    - `mkdir /var/log/borg`
