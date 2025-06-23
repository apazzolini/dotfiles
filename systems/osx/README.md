# ghostty

`mkdir -p ~/.config`
`ln -s ~/.dotfiles/systems/osx/ghostty ~/.config/`

# brew.sh

Invoke to install default homebrew packages

# set-defaults.sh

Applies my OS X default settings

# others

```
ln -s ~/.dotfiles/systems/osx/hammerspoon ~/.hammerspoon
ln -s ~/.dotfiles/systems/osx/karabiner.json ~/.config/karabiner/karabiner.json
```
- Command X
- Alfred
- iStatMenus
- Hyperduck
- Amphetamine
- Dato
- iTerm2 (configure in-app to load prefs from dotfiles)
- Deskflow 1.21.1.0
- SaneSideButtons
- MiddleClick.app

# borg

Needs borg-passphrase item (kind=secret) in Keychain
```
brew install borgbackup
ln -s ~/.dotfiles/systems/osx/borg.plist ~/Library/LaunchAgents/borg.plist
launchctl load ~/Library/LaunchAgents/borg.plist
```


