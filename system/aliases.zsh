# ls aliases
if [ `uname` = 'Darwin' ]
then
    alias ls="ls -F"
else
    alias ls="ls -F --color"
fi
alias l="gls -Flh --group-directories-first --color"
alias la="ls -A"
alias ll="l -A"
alias llg="ll | grep"

# easy navigating
alias ..="cd .."
alias ...="cd ../.."

# history aliases
alias hall='history 1 -1'
alias h='history -30 -1'
alias hg='history 1 -1 | grep '

# process aliases
alias pg='ps -Aef | head -1 && ps -Aef | grep'
alias pgn="pg node | grep -v Postman | grep -v Hyper | grep -v _d | grep -v '(node)' | grep -v grep | grep -v javascript-typescript-stdio | grep -v 'There Helper' | grep -v YakYak | grep -v tsserver"
alias k='kill -9'
alias fk='fkill'

# open current window in path finder
# alias o='open -a "/Applications/Finder.app" .'
alias o='open .'

# copies public ssh key to clipboard
alias pubkey="more ~/.ssh/id_rsa.pub | pbcopy | echo '=> Public key copied to pasteboard.'"

# copies current directory to clipboard
alias curdir="pwd | tr -d '\n' | pbcopy"

# starts up a webserver at the current directory
alias httpserver="python -m SimpleHTTPServer 9090"

# use hub to front git
if $(hub &>/dev/null)
then
  alias git='hub'
fi

# open current directory in sourcetree
alias st='stree'
alias sf='fork'

# ranger
alias r='ranger'

# shortcuts for npm/yarn
alias nr="npm run"
alias yr="yarn run"
alias yt="yarn run test"
alias ytw="yarn test:watch"

# tmux
alias t="tmux -u -2"
alias ta="t attach -t"
alias td="t detach"
alias tawork="base16_ashes && /Users/Andre/.dotfiles/tmux/sessions/work.sh"
alias tadre="base16_ashes && /Users/Andre/.dotfiles/tmux/sessions/dre.sh"
alias iris="tmux new-window -k -n iris -c '/Users/Andre/GitHub/_forks/qmk_firmware/keyboards/keebio/iris/keymaps/apazzolini'"

# vim
alias v='/usr/local/bin/nvim'
alias vi='/usr/local/bin/nvim'
alias vim='/usr/local/bin/nvim'
alias vf='v "$(fzf)"'
alias notes='base16_harmonic-light && VIMNOTES=1 v -u ~/.dotfiles/vim/vimnotes -O ~/Air/Wiki/diary/diary.md ~/Air/Wiki/index.md'

# misc
alias d='docker'
alias dl='docker-compose -f ~/Work/Float/dws/docker-compose/docker-compose.yml -f ~/Work/Float/dws/docker-compose/docker-compose.local.yml'
alias jest='nocorrect jest'
alias ava='nocorrect ava'
alias rg='rg -i'
alias fix='echo -e "\033c"; stty sane; tput rs1'
alias j='z'
alias har='base16_harmonic-light'
alias ash='base16_ashes'
alias trackpad='osascript /Users/Andre/Documents/toggle-internal-trackpad.scpt'
