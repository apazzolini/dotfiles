set undodir=~/.vim/.undo
set backupdir=~/.vim/.bak
set directory=~/.vim/.swap
set foldmethod=indent
set foldnestmax=10
set nofoldenable
set foldlevel=1
set mouse=a

if has('gui_running')
  set guifont=Operator\ Mono\ Book:h11
  set go-=T         " Hide MacVim toolbar
  set go-=L         " Hide left scrollbar
  set showtabline=2 " Always show tabs, even if there is only one
endif
