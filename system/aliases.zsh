# ls aliases
#alias ls='ls --color=auto'
alias l='ls -l'
alias la='ls -a'
alias ll='ls -la'
alias lsd='ls -l | grep "^d"'

# easy navigating
alias ..="cd .."
alias ...="cd ../.."

# history alias
alias hall='history 1 -1'
alias h='history -30 -1'

# process list helpers
alias pg='ps -A | grep '
alias psa='ps -A'

# open current window in path finder
alias o='open -a "Path Finder.app" .'

# atea (https://github.com/pkamenarsky/atea)
alias t='vim /Users/Andre/Dropbox/Random/tasks.txt'

# copies public ssh key to clipboard
alias pubkey="more ~/.ssh/id_dsa.pub | pbcopy | echo '=> Public key copied to pasteboard.'"

# GRC colorizes nifty unix tools all over the place
if $(grc &>/dev/null)
then
  source `brew --prefix`/etc/grc.bashrc
fi
