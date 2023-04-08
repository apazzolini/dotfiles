# matches case insensitive for lowercase
zstyle ':completion:*' matcher-list 'm:{a-z}={A-Z}'

# pasting with tabs doesn't perform completion
zstyle ':completion:*' insert-tab pending

# colors during completion
zstyle ':completion:*' list-colors ${(s.:.)LS_COLORS}

# better completion menu
zstyle ':completion:*' menu select

safesource "$ZSH/zsh/completions/doppler.zsh"
safesource "/usr/local/opt/fzf/shell/completion.zsh"
safesource "/opt/homebrew/opt/fzf/shell/completion.zsh"
safesource "/usr/share/doc/fzf/examples/completion.zsh"
safesource "~/.bun/_bun"
