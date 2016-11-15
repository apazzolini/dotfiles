set undodir=~/.config/nvim/.undo
set backupdir=~/.config/nvim/.bak
set directory=~/.config/nvim/.swap
set foldmethod=indent
set foldnestmax=10
set nofoldenable
set foldlevel=1
set mouse=a

set inccommand=split

function! Sol()
  set background=light
  colorscheme Solarized
endfunction
command! Sol call Sol()
