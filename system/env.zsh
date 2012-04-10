# Environment Variables
export EDITOR='mvim'
export MANPAGER="less -X"
export LSCOLORS=exfxcxdxbxegedabagacad
export CLICOLOR=true
export HISTFILE=~/.zsh_history
export HISTSIZE=1000000
export SAVEHIST=1000000
export JAVA_HOME=/System/Library/Frameworks/JavaVM.framework/Versions/1.6/Home
export MVN_HOME=/usr/lib/apache-maven-3.0.2
export MULE_HOME=/usr/lib/mule-standalone-3.1.2
export GRAILS_HOME=/usr/lib/grails-2.0.0
export MAGICK_HOME=/usr/lib/ImageMagick
export NODE_PATH="/usr/local/lib/node"
export MANPATH="/usr/local/man:/usr/local/mysql/man:/usr/local/git/man:$MANPATH"
export PATH="opt/local/bin:$ZSH/bin:$ZSH/bin/private:$PATH"

# Environment settings
setopt NO_BG_NICE # don't nice background tasks
setopt NO_HUP
setopt NO_LIST_BEEP
setopt LOCAL_OPTIONS # allow functions to have local options
setopt LOCAL_TRAPS # allow functions to have local traps
setopt HIST_VERIFY
setopt SHARE_HISTORY # share history between sessions ???
setopt EXTENDED_HISTORY # add timestamps to history
setopt PROMPT_SUBST
setopt CORRECT
setopt COMPLETE_IN_WORD
setopt IGNORE_EOF
setopt APPEND_HISTORY
setopt INC_APPEND_HISTORY SHARE_HISTORY
setopt HIST_IGNORE_ALL_DUPS
setopt HIST_REDUCE_BLANKS
setopt complete_aliases # don't expand aliases _before_ completion has finished like: git comm-[tab]

# Use VI mode in the shell
set -o vi

# Prompt
if [ $UID -eq 0 ]; then CARETCOLOR="red"; else CARETCOLOR="blue"; fi
local return_code="%(?..%{$fg[red]%}%? ↵%{$reset_color%})"
PROMPT='%{$reset_color%}%{${fg[green]}%}%10~ $(git_prompt_info)%{${fg_bold[$CARETCOLOR]}%}»%{${reset_color}%} '
RPROMPT='[%*] ${return_code}'
ZSH_THEME_GIT_PROMPT_PREFIX="%{$fg[yellow]%}‹"
ZSH_THEME_GIT_PROMPT_SUFFIX="› %{$reset_color%}"
ZSH_THEME_GIT_PROMPT_DIRTY="*"              # Text to display if the branch is dirty

ZSH_THEME_GIT_PROMPT_CLEAN=""               # Text to display if the branch is clean
