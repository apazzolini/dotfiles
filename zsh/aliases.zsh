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

if [[ `hostname` = andrem2* ]]
then
  alias dl='docker-compose -f /Users/andre/Work/docker/docker-compose.yml'
  alias notes='IS_NOTES=1 nvim -O "/Users/andre/Work/notes/log.md"'
else
  alias dl='docker-compose -f /apps/docker-compose.yml'
  alias notes='IS_NOTES=1 nvim -O "/Users/andre/Library/Mobile Documents/com~apple~CloudDocs/Wiki/index.md"'
fi

# ls aliases
alias l="ls -lh --group-directories-first"
alias ll="l -A"

# history aliases
alias hall='history 1 -1'
alias h='history -30 -1'
alias hg='history 1 -1 | grep '

# process aliases
alias pg='ps -Aef | head -1 && ps -Aef | grep'
alias pgn="pg node | grep -v '(node)' | grep -vE '(grep|javascript-typescript-stdio|tsserver)'"
alias k='kill -9'

# starts up a webserver at the current directory
alias httpserver="python -m SimpleHTTPServer 9090"

# git aliases
alias lg='lazygit -ucd ~/.config/lazygit'

# shortcuts for npm/yarn
alias yr="yarn run"
alias nr="npm run"
alias pr="pnpm run"

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
alias vrc='nvim -c "cd ~/.dotfiles" -- ~/.dotfiles/nvim/init.vim'
alias vp='nvim package.json'

# misc
alias d='docker'
alias da='d ps -a'
alias j=z
alias rg='rg -i'

# work
alias pgbak='~/work/backup-pg.sh'
alias pgres='~/work/restore-pg.sh'
alias pgls='ll /Users/andre/Work/docker/pgdatabackup/'
alias pgcd='cd /Users/andre/Work/docker/pgdatabackup/'
alias houston='HOST="https://houston.doppler.team" /Users/andre/Work/houston/scripts/houston.sh'
alias houston-staging='HOST="https://houston.staging.doppler.team" /Users/andre/Work/houston/scripts/houston.sh'
alias dop='doppler'
alias ds='doppler secrets'

alias sudoedit='sudo -e'
