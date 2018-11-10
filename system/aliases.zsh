# ls aliases
if [ `uname` = 'Darwin' ]
then
    alias ls="ls -F"
else
    alias ls="ls -F --color"
fi
alias l="ls -lh"
alias la="ls -A"
alias ll="ls -lAh"
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
alias pgn="pg node | grep -v Postman | grep -v Hyper | grep -v _d | grep -v '(node)' | grep -v grep | grep -v javascript-typescript-stdio | grep -v 'There Helper'"
alias ka='killall'
alias k='kill -9'
alias knode='pkill -9 -f '\''node --expose-gc'\'
alias fk='fkill'

# open current window in path finder
alias o='open -a "/Applications/Path Finder.app" .'

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
alias st='open -a "/Applications/SourceTree.app" `pwd`'
alias stf='open -a "/Applications/SourceTree.app" `pwd` && fg'
alias sf='open -a "/Applications/Fork.app" `pwd`'
alias sff='open -a "/Applications/Fork.app" `pwd` && fg'

# ranger
alias r='ranger'

# shortcuts for npm run
alias nr="npm run"
alias nrt="npm run -s test"
alias nrl="npm run -s lint"
alias nrs="npm run -s start"
alias yr="yarn run"
alias ys="yarn run start"
alias yl="yarn run lint"
alias yt="yarn run test"
alias ytw="yarn test:watch"

# tmux
alias t="tmux -u -2"
alias ta="t attach -t"
alias td="t detach"
alias tawork="/Users/Andre/.dotfiles/tmux/sessions/work.sh"
alias tadre="/Users/Andre/.dotfiles/tmux/sessions/dre.sh"

# vim
alias v='NVIM_TUI_ENABLE_TRUE_COLOR=1 /usr/local/bin/nvim'
alias vi='NVIM_TUI_ENABLE_TRUE_COLOR=1 /usr/local/bin/nvim'
alias vim='NVIM_TUI_ENABLE_TRUE_COLOR=1 /usr/local/bin/nvim'
alias nvim='NVIM_TUI_ENABLE_TRUE_COLOR=1 /usr/local/bin/nvim'
alias vf='v "$(fzf)"'
alias notes='v -u ~/.dotfiles/vim/vimnotes -O ~/Air/Wiki/diary/diary.wiki ~/Air/Wiki/index.wiki'

# misc
alias d='docker'
alias kafkacat="kafkacat -X broker.version.fallback=0.8.2.2 -b 10.0.101.172"
alias jest='nocorrect jest'
alias rg='rg -i'
alias fix='echo -e "\033c"; stty sane; tput rs1'

# sudo aliases
alias sv='sudo NVIM_TUI_ENABLE_TRUE_COLOR=1 /usr/local/bin/nvim'
alias sd='sudo docker'
