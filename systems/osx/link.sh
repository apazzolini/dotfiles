function link {
  src="$HOME/.dotfiles/$1"
  dst="$2"
  ln -sfv "$src" "$dst"
}

mkdir -p ~/.config/karabiner
link systems/osx/karabiner.json ~/.config/karabiner/karabiner.json

link systems/osx/ghostty ~/.config/
link systems/osx/hammerspoon ~/.hammerspoon

curl -fsSL https://raw.githubusercontent.com/tj/n/master/bin/n | sudo bash -s lts
sudo mkdir -p /usr/local/n
sudo chown -R $(whoami) /usr/local/n
sudo mkdir -p /usr/local/bin /usr/local/lib /usr/local/include /usr/local/share
sudo chown -R $(whoami) /usr/local/bin /usr/local/lib /usr/local/include /usr/local/share
npm install -g n
