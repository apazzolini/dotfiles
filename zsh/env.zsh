# Environment Variables
export EDITOR='nvim'
export MANPAGER='nvim +Man!'
export CLICOLOR=true
export HISTFILE=~/.zsh_history
export HISTSIZE=10000000
export SAVEHIST=$HISTSIZE
export PATH="/home/andre/.local/bin:./node_modules/.bin:$PATH:../node_modules/.bin"
export PGDATA='/usr/local/var/postgres'
export IGNOREEOF=50
export LSCOLORS="ExGxBxDxCxEgEdxbxgxcxd"

export RG_GLOBS='-g "*.*"\
  -g "config/local.js"\
  -g "!.git"\
  -g "!es5"\
  -g "!dist"\
  -g "!.next"\
  -g "!build/"\
  -g "!**/__fixtures__/**"\
  -g "!**/__snapshots__/**"\
  -g "!yarn.lock"\
  -g "!.DS_Store"\
  -g "!.cache"\
  -g "!**/nvim/plugged"\
  -g "!flow-typed"'

export FZF_DEFAULT_COMMAND="rg --color=never --files --hidden --smart-case --follow $RG_GLOBS"
export FZF_DEFAULT_OPTS='--reverse --border --bind=ctrl-d:half-page-down,ctrl-u:half-page-up
  --color=bg+:18,bg:0,spinner:12,hl:14
  --color=fg:7,header:14,info:10,pointer:12
  --color=marker:12,fg+:6,prompt:10,hl+:13'
export FZF_CTRL_T_COMMAND="$FZF_DEFAULT_COMMAND"

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

# Use VI mode in the shell
bindkey -v
