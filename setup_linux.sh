#!/bin/bash

set -o errexit
set -o errtrace
set -o nounset
set -o pipefail

sudo apt update
sudo apt install zsh keychain ripgrep fzf git ninja-build gettext libtool libtool-bin autoconf automake cmake g++ pkg-config unzip curl golang htop man tmux wget -y

cd ~/.dotfiles
./link.sh
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
#!/bin/bash
git fetch --tags --force && git checkout stable
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
echo "INSTALL GIT-DELTA"
