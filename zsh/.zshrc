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

# initialize autosuggetsions and bind accept to ctrl+space
source /usr/share/zsh-autosuggestions/zsh-autosuggestions.zsh
bindkey '^ ' autosuggest-accept

# initialize fasd
eval "$(fasd --init zsh-hook zsh-ccomp zsh-ccomp-install zsh-wcomp zsh-wcomp-install)"

[ -f ~/.fzf.zsh ] && source ~/.fzf.zsh
