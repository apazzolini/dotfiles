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
- Configure Restic:

    - `brew install restic`
    - Add restic-password to OS X keychain
    - Download restic-append-keys.zip and extract to ~/.ssh/
    - `ln -s ~/.dotfiles/systems/osx/restic.plist ~/Library/LaunchAgents/restic.plist`
    - `launchctl load ~/Library/LaunchAgents/restic.plist`
    - `sudo mkdir /var/log/restic`
    - `sudo chown andre /var/log/restic`

