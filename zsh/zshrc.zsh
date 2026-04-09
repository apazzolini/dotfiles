# zmodload zsh/zprof
# initialize colors
autoload colors && colors

# initialize autocomplete
fpath=(
  $ZSH/zsh/functions
  /opt/homebrew/share/zsh/site-functions
  $fpath
)
# autoload -Uz compinit
# if [[ ! -f ~/.zcompdump ]] || [[ $(find ~/.zcompdump -mtime +7) ]]; then
#   compinit
# else
#   compinit -C  # Fast mode using cache
# fi

compinit_deferred() {
  unfunction compdef 2>/dev/null
  autoload -Uz compinit && compinit "$@"
}
compdef() {
  compinit_deferred
  compdef "$@"
}

# initialize custom functions
autoload -U $ZSH/zsh/functions/*(:t)

# allow editing current command in $EDITOR
autoload -U edit-command-line
zle -N edit-command-line
bindkey -M vicmd g edit-command-line

# initialize prompt
export STARSHIP_CONFIG=${HOME}/.config/starship.toml
eval "$(starship init zsh)"
# export PS1=$'%{\e[38;5;245m%}${(r:$COLUMNS::\u2500:)}%{\e[0m%}'$PS1
# export PS1=$'%{\e[38;5;245m%}${(r:$COLUMNS:: :)}%{\e[0m%}'$PS1
# export RPROMPT="[%D{%L:%M:%S}]"

function safesource {
  [ -f "$1" ] && source "$1"
}

source $ZSH/zsh/zsh-defer/zsh-defer.plugin.zsh

source $ZSH/zsh/aliases.zsh
source $ZSH/zsh/completion.zsh
# zsh-defer source $ZSH/zsh/fzf-tab/fzf-tab.plugin.zsh
source $ZSH/bin/restic.zsh
source $ZSH/bin/applypatch.zsh

zsh-defer eval "$(zoxide init zsh)"

export HISTFILE=~/.zsh_history
export HISTSIZE=10000000
export SAVEHIST=$HISTSIZE
setopt HIST_VERIFY
# setopt SHARE_HISTORY # share history between sessions
setopt EXTENDED_HISTORY # add timestamps to history
setopt APPEND_HISTORY
setopt INC_APPEND_HISTORY
setopt HIST_IGNORE_ALL_DUPS
setopt HIST_REDUCE_BLANKS
setopt HIST_IGNORE_SPACE

# initialize autosuggetsions and bind accept to ctrl+space
zsh-defer source $ZSH/zsh/zsh-autosuggestions/zsh-autosuggestions.zsh
zsh-defer bindkey '^ ' autosuggest-accept

safesource "/usr/local/opt/fzf/shell/key-bindings.zsh"
safesource "/opt/homebrew/opt/fzf/shell/key-bindings.zsh"
safesource "/usr/share/doc/fzf/examples/key-bindings.zsh"
safesource "/usr/share/fzf/key-bindings.zsh"

if [ -z "$TMUX" ]; then
  if [[ "$__CFBundleIdentifier" =~ iterm2$ ]]; then
    return;
  fi;

  if [[ "$(hostname)" == arch ]]; then
    tmux-sessionizer /home/andre/.dotfiles
  fi;
fi

if [ -f "/etc/wsl.conf" ]; then
  ${HOME}/.dotfiles/bin/wsl-ssh-agent-relay start
  export SSH_AUTH_SOCK=${HOME}/.ssh/wsl-ssh-agent.sock
fi

# The next line updates PATH for the Google Cloud SDK.
# if [ -f '/Users/andre/code/google-cloud-sdk/path.zsh.inc' ]; then . '/Users/andre/code/google-cloud-sdk/path.zsh.inc'; fi

# The next line enables shell command completion for gcloud.
# if [ -f '/Users/andre/code/google-cloud-sdk/completion.zsh.inc' ]; then . '/Users/andre/code/google-cloud-sdk/completion.zsh.inc'; fi

# bun completions
[ -s "/home/andre/.bun/_bun" ] && source "/home/andre/.bun/_bun"

zle -N fg_widget
bindkey '^z' fg_widget
# zprof
