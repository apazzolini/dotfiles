#!/bin/bash

set -o errexit
set -o errtrace
set -o nounset
set -o pipefail

sudo apt update
sudo apt install zsh ripgrep fzf git ninja-build gettext libtool libtool-bin autoconf automake cmake g++ pkg-config unzip curl golang -y

cd ~/.dotfiles
./link.sh
ln -s ~/.dotfiles/git/.gitconfig.local.windows ~/.gitconfig.local
sudo chown -R andre:andre /usr/local/
sh -c "$(curl -fsSL https://starship.rs/install.sh)"
sudo chsh andre -s /usr/bin/zsh

sudo apt upgrade -y

# Neovim
mkdir -p ~/GitHub
git clone https://github.com/neovim/neovim.git ~/GitHub/neovim
cd ~/GitHub/neovim
cat <<EOF > go.sh
make clean
sudo make distclean
make CMAKE_BUILD_TYPE=Release -j4
sudo make install
EOF
chmod +x go.sh
./go.sh

# Lazygit
cd ~/GitHub
git clone https://github.com/apazzolini/lazygit.git
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
npm i -g /home/andre/GitHub/prettier_d_slim

echo "https://github.com/dandavison/delta/releases"
