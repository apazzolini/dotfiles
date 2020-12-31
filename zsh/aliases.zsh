# ls aliases
if [ `uname` = 'Darwin' ]
then
  alias ls="gls -F --color"
else
  alias ls="ls -F --color"
fi
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

# misc
alias d='docker'
alias da='d ps -a'
alias j=z
alias rg='rg -i'
alias fix='echo -e "\033c"; stty sane; tput rs1'
#alias dl='docker-compose -f ~/Work/Float/dws/docker-compose/docker-compose.yml -f ~/Work/Float/dws/docker-compose/docker-compose.local.yml'
#alias jest='nocorrect jest'
#alias ava='nocorrect ava'

if [ `uname` = 'Darwin' ]
then
  alias trackpad='osascript ~/.dotfiles/bin/toggle-internal-trackpad.scpt'
  alias o='open .'
  alias pubkey="more ~/.ssh/id_rsa.pub | pbcopy | echo '=> Public key copied to pasteboard.'"
  alias curdir="pwd | tr -d '\n' | pbcopy"
else
  alias o='explorer.exe .'
fi
