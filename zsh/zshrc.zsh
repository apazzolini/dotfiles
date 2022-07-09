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

source $ZSH/zsh/aliases.zsh
source $ZSH/zsh/completion.zsh
source $ZSH/bin/z.sh
source $ZSH/bin/borg.zsh

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

# bun completions
[ -s "/Users/andre/.bun/_bun" ] && source "/Users/andre/.bun/_bun"

safesource /usr/share/doc/fzf/examples/key-bindings.zsh
safesource ~/.fzf.zsh
safesource /usr/local/Caskroom/google-cloud-sdk/latest/google-cloud-sdk/path.zsh.inc

alias luamake=/Users/andre/.cache/nvim/nlua/sumneko_lua/lua-language-server/3rd/luamake/luamake

if [ -z "$TMUX" ]; then
  if [[ "$(hostname)" =~ ^andrembw ]]; then
    return;
  fi;

  if [[ "$__CFBundleIdentifier" =~ iterm2$ ]]; then
    return;
  fi;

  tmux-sessionizer ~/.dotfiles
fi
