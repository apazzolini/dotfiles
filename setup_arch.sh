#!/bin/bash

set -o errexit
set -o errtrace
set -o nounset
set -o pipefail

cd ~/.dotfiles
./link.sh
sudo chown -R andre /usr/local/
sh -c "$(curl -fsSL https://starship.rs/install.sh)"
sudo chsh andre -s /usr/bin/zsh

sudo pacman -S ripgrep fzf htop tmux neovim go git-delta unzip

# Lazygit
cd ~/GitHub
git clone git@github.com:apazzolini/lazygit.git
cd lazygit
go install
go build
mv lazygit /usr/local/bin/

# Node
curl -fsSL https://raw.githubusercontent.com/tj/n/master/bin/n | bash -s lts
npm install -g n
npm install -g eslint_d
git clone https://github.com/apazzolini/prettier_d_slim.git ~/GitHub/prettier_d_slim
cd ~/GitHub/prettier_d_slim
npm i
./script/build
npm i -g $(pwd)

# Rust
# curl --proto '=https' --tlsv1.2 -sSf https://sh.rustup.rs | sh

# Tailwind
cd ~/GitHub
git clone https://github.com/apazzolini/tailwindcss-intellisense.git
cd tailwindcss-intellisense
npm i
cd packages/tailwindcss-language-server
npm run build
npm i -g $(pwd)

# misc
go install golang.org/x/tools/cmd/goimports@latest
cargo install stylua

# docker
sudo pacman -S docker
sudo systemctl start docker.service
sudo systemctl enable docker.service
sudo usermod -aG docker $USER
