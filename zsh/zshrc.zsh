# initialize colors
autoload colors && colors

# initialize autocomplete
fpath=(
  $ZSH/zsh/functions
  /opt/homebrew/share/zsh/site-functions
  $fpath
)
autoload -Uz compinit
compinit -C

# initialize custom functions
autoload -U $ZSH/zsh/functions/*(:t)

# allow editing current command in $EDITOR
autoload -U edit-command-line
zle -N edit-command-line
bindkey -M vicmd g edit-command-line

# initialize prompt
eval "$(starship init zsh)"
export RPROMPT="[%D{%L:%M:%S}]"

function safesource {
  [ -f "$1" ] && source "$1"
}

source $ZSH/zsh/aliases.zsh
source $ZSH/zsh/completion.zsh
source $ZSH/bin/z.sh
source $ZSH/bin/borg.zsh

# initialize autosuggetsions and bind accept to ctrl+space
safesource /usr/local/share/zsh-autosuggestions/zsh-autosuggestions.zsh
safesource /usr/share/zsh-autosuggestions/zsh-autosuggestions.zsh
safesource /opt/homebrew/share/zsh-autosuggestions/zsh-autosuggestions.zsh
bindkey '^ ' autosuggest-accept

safesource "/usr/local/opt/fzf/shell/key-bindings.zsh"
safesource "/opt/homebrew/opt/fzf/shell/key-bindings.zsh"
safesource "/usr/share/doc/fzf/examples/key-bindings.zsh"

if [ -z "$TMUX" ]; then
  # if [[ "$(hostname)" =~ ^andrem2 ]]; then
  #   return;
  # fi;

  if [[ "$__CFBundleIdentifier" =~ iterm2$ ]]; then
    return;
  fi;

  tmux-sessionizer ~/.dotfiles
fi

# unix ssh-agent
# if [ -f "/usr/bin/keychain" ]; then
#   /usr/bin/keychain --nogui --quiet --noask $HOME/.ssh/id_rsa
#   source $HOME/.keychain/andred-sh
# fi
