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
alias k='kill -9'

# open current window in path finder
alias o='open -a "/Applications/Path Finder.app" .'

# atea (https://github.com/pkamenarsky/atea)
alias t='vim /Users/Andre/Dropbox/Random/atea/tasks.txt'

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

# because why not
alias plz='sudo'

# javascript console
alias jsc='/System/Library/Frameworks/JavaScriptCore.framework/Versions/Current/Resources/jsc'

# toggle java_home
alias usejava6='export JAVA_HOME=$(/usr/libexec/java_home -v 1.6)'
alias usejava7='export JAVA_HOME=$(/usr/libexec/java_home -v 1.7)'
alias usejava8='export JAVA_HOME=$(/usr/libexec/java_home -v 1.8)'

# open current directory in sourcetree
alias st='open -a "/Applications/SourceTree.app" `pwd`'

# edit previous command in vi
alias r='fc -e vim'

# starts up jekyll
alias jek='jekyll serve --watch --drafts'

# opens iphone photos
alias viewpics='open -a "/Applications/Path Finder.app" /Users/Andre/AeroFS/Photos/iPhone'

# diffmerge
alias diffmerge='/Applications/DiffMerge.app/Contents/MacOS/DiffMerge'

# clean eclipse artifacts
alias cleaneclipse="find . -name '.classpath' -o -name 'target' -o -name '.settings' -o -name '.project' | xargs rm -rf"
