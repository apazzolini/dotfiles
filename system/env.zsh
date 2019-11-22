# Environment Variables
export EDITOR='nvim'
export MANPAGER="less -X"
export CLICOLOR=true
export HISTFILE=~/.zsh_history
export HISTSIZE=1000000
export SAVEHIST=1000000
export MANPATH="/usr/local/man:/usr/local/mysql/man:/usr/local/git/man:$MANPATH"
export PATH="/usr/local/sbin:$ZSH/bin:$ZSH/bin/private:./node_modules/.bin:/usr/local/bin:$HOME/.yarn/bin:$HOME/.config/yarn/global/node_modules/.bin:$PATH"
export PGDATA='/usr/local/var/postgres'
export IGNOREEOF=50

export RG_GLOBS='-g "*.*" -g "config/local.js" -g "!.git" -g "!es5" -g "!dist" -g "!.next" -g "!build/" -g "!**/__fixtures__/**" -g "!**/__snapshots__/**" -g "!tmux.symlink/resurrect*" -g "!tmux.symlink/plugins" -g "!vim.symlink/plugged" -g "!yarn.lock" -g "!.DS_Store" -g "!.cache" -g "!*/vim.symlink/plugged" -g "!*/tmux.symlink/plugins"'
export FZF_DEFAULT_COMMAND="rg --color=never --files --hidden --smart-case --follow $RG_GLOBS"
export FZF_DEFAULT_OPTS='--reverse --border --bind=ctrl-d:half-page-down,ctrl-u:half-page-up
  --color=bg+:18,bg:0,spinner:12,hl:14
  --color=fg:7,header:14,info:10,pointer:12
  --color=marker:12,fg+:6,prompt:10,hl+:13
'

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
setopt HIST_IGNORE_SPACE
setopt complete_aliases # don't expand aliases _before_ completion has finished like: git comm-[tab]
setopt auto_cd # allow changing to a directory without typing "cd "

# Use VI mode in the shell
bindkey -v
bindkey "^R" history-incremental-pattern-search-backward

autoload -U edit-command-line
zle -N edit-command-line
bindkey -M vicmd g edit-command-line

# Prompt
if [ $UID -eq 0 ]; then CARETCOLOR="red"; else CARETCOLOR="blue"; fi
local return_code="%(?..%{$fg[red]%}%? ↵%{$reset_color%})"

if [[ `hostname` == *andrembp* ]]; then
    PROMPT='%{$reset_color%}%{${fg[blue]}%}%10~ $(gitprompt)%{${fg_bold[$CARETCOLOR]}%}»%{${reset_color}%} '
else
    PROMPT='[%m] %{$reset_color%}%{${fg[blue]}%}%10~ $(gitprompt)%{${fg_bold[$CARETCOLOR]}%}»%{${reset_color}%} '
fi

#RPROMPT='[%*] ${return_code}'
ZSH_THEME_GIT_PROMPT_PREFIX="%{$fg[yellow]%}‹"
ZSH_THEME_GIT_PROMPT_SUFFIX="› %{$reset_color%}"
ZSH_THEME_GIT_PROMPT_DIRTY="*"              # Text to display if the branch is dirty
ZSH_THEME_GIT_PROMPT_CLEAN=""               # Text to display if the branch is clean

# GRC colorizes nifty unix tools all over the place
if $(grc &>/dev/null)
then
  source `brew --prefix`/etc/grc.bashrc
fi
