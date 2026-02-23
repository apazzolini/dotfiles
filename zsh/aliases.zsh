if [ `uname` = 'Darwin' ]
then
  alias ls="gls -F --color"
  alias trackpad='osascript ~/.dotfiles/bin/toggle-internal-trackpad.scpt'
  alias o='open .'
  alias pubkey="more ~/.ssh/id_rsa.pub | pbcopy | echo '=> Public key copied to pasteboard.'"
  alias curdir="pwd | tr -d '\n' | pbcopy"
else
  alias ls="ls -F --color"
  alias o='explorer.exe .'
fi

if [[ `hostname` = G16JTXJGPY ]]; then
  # alias dl='docker compose -f /Users/andre/Work/docker/docker-compose.yml'
  alias notes='IS_NOTES=1 nvim -O "/Users/andre.azzolini/work/notes/log.md"'
else
  alias dl='docker compose -f /apps/docker-compose.yml'
  alias notes='IS_NOTES=1 nvim -O "/Users/andre/Library/Mobile Documents/com~apple~CloudDocs/Wiki/personal/scratch.md"'
fi

# ls aliases
alias l="ls -lh --group-directories-first"
alias ll="l -A"

# history aliases
alias hall='history 1 -1'
alias h='history -30 -1'
alias hg='history 1 -1 | grep '

# process aliases
alias pgn="pg node | grep -v '(node)' | grep -vE '(grep|javascript-typescript-stdio|tsserver)'"
alias k='kill -9'

# starts up a webserver at the current directory
alias httpserver="python3 -m http.server 9090"

# git aliases
alias lg='lazygit -ucd ~/.config/lazygit'
alias lj='jjui'
alias gs='git status'

# shortcuts for npm/yarn
alias yr="yarn run"
alias y="yarn"
alias ys="yarn start"
alias yi="yarn install"
alias nr="npm run"
alias br="bun run"
alias rt='~/.dotfiles/bin/review-tags.sh'

# tmux
alias t="tmux-sessionizer"
alias ta="tmux -u -2 attach"
alias td="tmux -u -2 detach"
alias tks="tmux -u -2 kill-session"

# vim
alias v="nvim"
alias vi="nvim"
alias vim="nvim"
alias vf='nvim "$(fzf)"'
alias vrc='nvim -c "cd ~/.dotfiles" -- ~/.dotfiles/nvim/init.lua'
alias vp='nvim package.json'

# misc
alias d='docker'
alias da='d ps -a'
alias j=z
alias oc='opencode'

# work
alias ks="fuser -k 3000/tcp 16823/tcp"

alias sudoedit='sudo -e'

alias lazy='cd ~/.local/share/nvim/lazy'
