# ls aliases
if [ `uname` = 'Darwin' ]
then
  alias ls="ls -F"
else
  alias ls="ls -F --color"
fi
alias l="ls -Flh --group-directories-first --color"
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

# open current directory in sourcetree
alias st='stree'

# shortcuts for npm/yarn
alias yr="yarn run"
alias yt="yarn run test"
alias ytw="yarn test:watch"

# tmux
alias t="tmux -u -2"
alias ta="t attach -t"
alias td="t detach"
alias tks="t kill-session"
alias tawork="$HOME/.dotfiles/tmux/sessions/work.sh"
alias tadre="$HOME/.dotfiles/tmux/sessions/dre.sh"

# vim
alias v=nvim
alias vi=nvim
alias vim=nvim
alias vf='nvim "$(fzf)"'

# fasd
alias j='fasd_cd'

# misc
alias d='docker'
alias rg='rg -i'
alias fix='echo -e "\033c"; stty sane; tput rs1'
#alias dl='docker-compose -f ~/Work/Float/dws/docker-compose/docker-compose.yml -f ~/Work/Float/dws/docker-compose/docker-compose.local.yml'
#alias jest='nocorrect jest'
#alias ava='nocorrect ava'
#alias trackpad='osascript /Users/Andre/Documents/toggle-internal-trackpad.scpt'
