# Environment Variables
export EDITOR='/usr/local/bin/nvim'
export MANPAGER='nvim +Man!'
export CLICOLOR=true
export HISTFILE=~/.zsh_history
export HISTSIZE=10000000
export SAVEHIST=$HISTSIZE
export PATH="$HOME/.dotfiles/bin:/usr/local/go/bin:/Users/andre/.cargo/bin:/home/andre/.local/bin:./node_modules/.bin:/usr/local/opt:/usr/local/sbin:/usr/local/opt/postgresql@11/bin:$PATH:../node_modules/.bin"
export PGDATA='/usr/local/var/postgres'
export IGNOREEOF=50
export LSCOLORS="ExGxBxDxCxEgEdxbxgxcxd"
export LS_COLORS='rs=0:di=00;34:ln=00;36:mh=00:pi=40;33:so=00;35:do=00;35:bd=40;33;01:cd=40;33;01:or=40;31;01:mi=01;05;37;41:su=37;41:sg=30;43:ca=30;41:tw=30;42:ow=34;42:st=37;44:ex=00;32:*.tar=00;31:*.tgz=00;31:*.arc=00;31:*.arj=00;31:*.taz=00;31:*.lha=00;31:*.lz4=00;31:*.lzh=00;31:*.lzma=00;31:*.tlz=00;31:*.txz=00;31:*.tzo=00;31:*.t7z=00;31:*.zip=00;31:*.z=00;31:*.Z=00;31:*.dz=00;31:*.gz=00;31:*.lrz=00;31:*.lz=00;31:*.lzo=00;31:*.xz=00;31:*.bz2=00;31:*.bz=00;31:*.tbz=00;31:*.tbz2=00;31:*.tz=00;31:*.deb=00;31:*.rpm=00;31:*.jar=00;31:*.war=00;31:*.ear=00;31:*.sar=00;31:*.rar=00;31:*.alz=00;31:*.ace=00;31:*.zoo=00;31:*.cpio=00;31:*.7z=00;31:*.rz=00;31:*.cab=00;31:*.jpg=00;35:*.jpeg=00;35:*.gif=00;35:*.bmp=00;35:*.pbm=00;35:*.pgm=00;35:*.ppm=00;35:*.tga=00;35:*.xbm=00;35:*.xpm=00;35:*.tif=00;35:*.tiff=00;35:*.png=00;35:*.svg=00;35:*.svgz=00;35:*.mng=00;35:*.pcx=00;35:*.mov=00;35:*.mpg=00;35:*.mpeg=00;35:*.m2v=00;35:*.mkv=00;35:*.webm=00;35:*.ogm=00;35:*.mp4=00;35:*.m4v=00;35:*.mp4v=00;35:*.vob=00;35:*.qt=00;35:*.nuv=00;35:*.wmv=00;35:*.asf=00;35:*.rm=00;35:*.rmvb=00;35:*.flc=00;35:*.avi=00;35:*.fli=00;35:*.flv=00;35:*.gl=00;35:*.dl=00;35:*.xcf=00;35:*.xwd=00;35:*.yuv=00;35:*.cgm=00;35:*.emf=00;35:*.axv=00;35:*.anx=00;35:*.ogv=00;35:*.ogx=00;35:*.aac=00;36:*.au=00;36:*.flac=00;36:*.mid=00;36:*.midi=00;36:*.mka=00;36:*.mp3=00;36:*.mpc=00;36:*.ogg=00;36:*.ra=00;36:*.wav=00;36:*.axa=00;36:*.oga=00;36:*.spx=00;36:*.xspf=00;36:'
export RPROMPT="[%D{%L:%M:%S}]"

export RG_GLOBS='-g "*.*"\
  -g "config/local.js"\
  -g "!com.googlecode.iterm2.plist"\
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
  --color=bg+:244,bg:0,spinner:12,hl:14
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
unsetopt correct # disable annoying correct prompt

# Use VI mode in the shell
bindkey -v
