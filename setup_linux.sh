#!/bin/bash

set -o errexit
set -o errtrace
set -o nounset
set -o pipefail

sudo apt update
sudo apt install zsh keychain ripgrep fzf git ninja-build gettext libtool libtool-bin autoconf automake cmake g++ pkg-config unzip curl golang htop man tmux wget -y

cd ~/.dotfiles
./link.sh
# ln -s ~/.dotfiles/git/.gitconfig.local.windows ~/.gitconfig.local
sudo chown -R andre:andre /usr/local/
sh -c "$(curl -fsSL https://starship.rs/install.sh)"
sudo chsh andre -s /usr/bin/zsh

sudo apt upgrade -y

sudo chown -R andre:andre /usr/local/

# Neovim
mkdir -p ~/GitHub
git clone git@github.com:neovim/neovim.git ~/GitHub/neovim
cd ~/GitHub/neovim
git co v0.9.5
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
git clone git@github.com:apazzolini/lazygit.git
cd lazygit
go install
go build
mv lazygit /usr/local/bin/

# Node
curl -fsSL https://raw.githubusercontent.com/tj/n/master/bin/n | bash -s lts
npm install -g n
npm install -g eslint_d
npm install -g @fsouza/prettierd

# Rust
curl --proto '=https' --tlsv1.2 -sSf https://sh.rustup.rs | sh

# Tailwind
git clone git@github.com:apazzolini/tailwindcss-intellisense.git ~/GitHub/tailwindcss-intellisense
cd ~/GitHub/tailwindcss-intellisense
git co andre/show-equivs
npm i
npm run bootstrap
cd packages/tailwindcss-language-server
NODE_OPTIONS=--openssl-legacy-provider npm run build
npm i -g $(pwd)

# misc
go install golang.org/x/tools/cmd/goimports@latest
cargo install stylua
echo "INSTALL GIT-DELTA"
