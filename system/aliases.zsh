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
alias pg='ps -A | grep '
alias psa='ps -A'
alias ka='killall'
alias pgj='ps -Aef | grep java'
alias kaj='killall java'

# open current window in path finder
alias o='open -a "Path Finder.app" .'

# atea (https://github.com/pkamenarsky/atea)
alias t='vim /Users/Andre/Dropbox/Random/atea/tasks.txt'

# copies public ssh key to clipboard
alias pubkey="more ~/.ssh/id_dsa.pub | pbcopy | echo '=> Public key copied to pasteboard.'"

# starts up a webserver at the current directory
alias httpserver="python -m SimpleHTTPServer 9090"

# use hub to front git
alias git='hub'

# because why not
alias plz='sudo'

# javascript console
alias jsc='/System/Library/Frameworks/JavaScriptCore.framework/Versions/Current/Resources/jsc'

# toggle java_home
alias usejava6='export JAVA_HOME=/System/Library/Frameworks/JavaVM.framework/Versions/1.6/Home'
alias usejava7='export JAVA_HOME=/Library/Java/JavaVirtualMachines/jdk1.7.0_25.jdk/Contents/Home'

# open current directory in sourcetree
alias st='open -a SourceTree `pwd`'

# edit previous command in vi
alias evi='fc -e vim'

# starts up jekyll
alias jek='jekyll serve --watch --drafts'
