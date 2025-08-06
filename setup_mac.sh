#!/bin/bash

set -o errexit
set -o errtrace
set -o nounset
set -o pipefail

cd ~/.dotfiles
./link.sh

cd ~/.dotfiles/systems/osx
./link.sh
./set-defaults.sh
./brew.sh
