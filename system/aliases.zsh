# ls aliases
alias ls="ls -F"
alias l="ls -lh"
alias ll="ls -lAh"
alias la="ls -A"

# easy navigating
alias ..="cd .."
alias ...="cd ../.."

# history aliases
alias hall='history 1 -1'
alias h='history -30 -1'
alias hg='history 1 -1 | grep '

# process aliases
alias pg='ps -Aef | head -1 && ps -Aef | grep'
alias psa='ps -A'
alias ka='killall'
alias pgj='ps -Aef | grep java'
alias kaj='killall java'
alias k='kill -9'
alias knode='pkill -9 -f '\''node --expose-gc'\'

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

# toggle java_home
alias usejava6='export JAVA_HOME=$(/usr/libexec/java_home -v 1.6)'
alias usejava7='export JAVA_HOME=$(/usr/libexec/java_home -v 1.7)'
alias usejava8='export JAVA_HOME=$(/usr/libexec/java_home -v 1.8)'

# open current directory in sourcetree
alias st='open -a "/Applications/SourceTree.app" `pwd`'

# edit previous command in vi
alias r='fc -e vim'

# opens iphone photos
alias viewpics='open -a "/Applications/Path Finder.app" /Users/Andre/AeroFS/Photos/iPhone'

# diffmerge
alias diffmerge='/Applications/DiffMerge.app/Contents/MacOS/DiffMerge'

# shortcuts for npm run
alias nr="npm run"
alias nrt="npm run -s test"
alias nrl="npm run -s lint"
alias nrs="npm run -s start"

# Ack
alias ackq="ack -Q"
alias ack="ag"

# Atom
alias cleanatom="rm -rf /Users/Andre/.atom/storage/editor-*"

# tmux
alias t="tmux -2"

alias kafkacat="kafkacat -X broker.version.fallback=0.8.2.2"
