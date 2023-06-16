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

export HISTFILE=~/.zsh_history
export HISTSIZE=10000000
export SAVEHIST=$HISTSIZE
setopt HIST_VERIFY
setopt SHARE_HISTORY # share history between sessions
setopt EXTENDED_HISTORY # add timestamps to history
setopt APPEND_HISTORY
setopt INC_APPEND_HISTORY
setopt HIST_IGNORE_ALL_DUPS
setopt HIST_REDUCE_BLANKS
setopt HIST_IGNORE_SPACE

# initialize autosuggetsions and bind accept to ctrl+space
source $ZSH/zsh/zsh-autosuggestions/zsh-autosuggestions.zsh
bindkey '^ ' autosuggest-accept

safesource "/usr/local/opt/fzf/shell/key-bindings.zsh"
safesource "/opt/homebrew/opt/fzf/shell/key-bindings.zsh"
safesource "/usr/share/doc/fzf/examples/key-bindings.zsh"

if [ -z "$TMUX" ]; then
  if [[ "$(hostname)" =~ ^andrem2 ]]; then
    sessions=("/Users/andre/.dotfiles" "/Users/andre/Work/server/review" "/Users/andre/Work/server/develop" "/Users/andre/Work/server/small")
    for session in $sessions
    do
      selected_name=$(basename "$session" | tr . _)
      tmux new-session -ds $selected_name -c $session
    done
  fi;

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

# The next line updates PATH for the Google Cloud SDK.
if [ -f '/Users/andre/GitHub/google-cloud-sdk/path.zsh.inc' ]; then . '/Users/andre/GitHub/google-cloud-sdk/path.zsh.inc'; fi

# The next line enables shell command completion for gcloud.
if [ -f '/Users/andre/GitHub/google-cloud-sdk/completion.zsh.inc' ]; then . '/Users/andre/GitHub/google-cloud-sdk/completion.zsh.inc'; fi
