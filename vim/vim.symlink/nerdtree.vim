let g:NERDTreeWinSize = 38
let NERDTreeMinimalUI = 1
let NERDTreeDirArrows = 1
let NERDTreeChDirMode = 2 " change vim working directory according to whatever the tree node is in NERDtree
let NERDTreeShowBookmarks = 1

map <D-0> :NERDTreeTabsToggle<CR>
map <D-l> :NERDTreeFind<CR>

let g:NERDTreeIndicatorMapCustom = {
  \ "Modified"  : "M",
  \ "Staged"    : "M",
  \ "Untracked" : "N",
  \ "Renamed"   : "R",
  \ "Unmerged"  : "M",
  \ "Deleted"   : "D",
  \ "Dirty"     : "M",
  \ "Clean"     : "A",
  \ "Unknown"   : "?"
  \ }

let g:nerdtree_tabs_open_on_gui_startup = 1
let g:nerdtree_tabs_focus_on_files = 1

if has('gui_vimr')
  autocmd StdinReadPre * let s:std_in=1
  autocmd VimEnter * if argc() == 0 && !exists("s:std_in") | NERDTree | endif
endif
