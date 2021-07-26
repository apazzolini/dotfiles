export ZSH=$HOME/.dotfiles

# initialize colors
autoload colors && colors

# initialize autocomplete
autoload -Uz compinit
compinit -C

# initialize custom functions
fpath=($ZSH/zsh/functions $fpath)
autoload -U $ZSH/zsh/functions/*(:t)

# allow editing current command in $EDITOR
autoload -U edit-command-line
zle -N edit-command-line
bindkey -M vicmd g edit-command-line

# initialize prompt
eval "$(starship init zsh)"

# source .zsh files in this repo
source $ZSH/zsh/env.zsh
source $ZSH/zsh/aliases.zsh
source $ZSH/zsh/completion.zsh
source $ZSH/bin/z.sh

function safesource {
  [ -f "$1" ] && source "$1"
}

# initialize autosuggetsions and bind accept to ctrl+space
safesource /usr/share/zsh-autosuggestions/zsh-autosuggestions.zsh
safesource /usr/local/share/zsh-autosuggestions/zsh-autosuggestions.zsh
safesource /opt/homebrew/share/zsh-autosuggestions/zsh-autosuggestions.zsh
bindkey '^ ' autosuggest-accept

# ssh-agent
if [ -f "/usr/bin/keychain" ]; then
  /usr/bin/keychain --nogui --quiet --noask $HOME/.ssh/id_rsa
  source $HOME/.keychain/andred-sh
fi

safesource /usr/share/doc/fzf/examples/key-bindings.zsh
safesource ~/.fzf.zsh
safesource /usr/local/Caskroom/google-cloud-sdk/latest/google-cloud-sdk/path.zsh.inc

# Extended colors as of 2020-01-04. Unable to specify these colors in
# Windows Terminal config, enable these lines to mimic the Alacritty cfg.
# printf "\033]4;16;rgb:c7/c7/95\033\\"
# printf "\033]4;17;rgb:c7/95/95\033\\"
# printf "\033]4;18;rgb:29/2e/33\033\\"
# printf "\033]4;19;rgb:56/5e/65\033\\"
# printf "\033]4;20;rgb:ad/b3/ba\033\\"
# printf "\033]4;21;rgb:df/e2/e5\033\\"
# printf "\033]4;22;rgb:a2/7f/74\033\\"
# printf "\033]4;244;rgb:2b/30/34\033\\"
# printf "\033]4;245;rgb:56/5e/65\033\\"
# printf "\033]4;246;rgb:74/7c/84\033\\"
# printf "\033]4;247;rgb:ad/b3/ba\033\\"
# printf "\033]4;248;rgb:c7/cc/d1\033\\"
# printf "\033]4;249;rgb:df/e2/e5\033\\"

alias luamake=/Users/andre/.cache/nvim/nlua/sumneko_lua/lua-language-server/3rd/luamake/luamake
