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
bindkey '^ ' autosuggest-accept


safesource ~/.fzf.zsh

safesource /usr/local/Caskroom/google-cloud-sdk/latest/google-cloud-sdk/path.zsh.inc
