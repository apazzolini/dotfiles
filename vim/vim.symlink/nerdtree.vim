let NERDTreeWinPos="left"
let NERDTreeMinimalUI = 1
let NERDTreeDirArrows = 1
let NERDTreeShowBookmarks = 0
let NERDTreeIgnore = ['node_modules', 'dist', 'es5', 'jsconfig.json']
let NERDTreeCascadeSingleChildDir=1
let NERDTreeQuitOnOpen = 1
let NERDTreeAutoDeleteBuffer = 1
let NERDTreeShowHidden=0
let g:NERDTreeMapOpenSplit="s"
let g:NERDTreeMapOpenVSplit="v"

map <leader>no :let NERDTreeQuitOnOpen=!NERDTreeQuitOnOpen<cr>
map <leader>nn :NERDTreeToggle<cr>

function! IsNERDTreeOpen()
  return exists("t:NERDTreeBufName") && (bufwinnr(t:NERDTreeBufName) != -1)
endfunction

function! NERDTreeFindOrDefault()
    try
        NERDTreeFind
    catch /.*/
    endtry
    if !IsNERDTreeOpen()
        NERDTree
    endif
endfunction

map <silent> <leader>g :call NERDTreeFindOrDefault()<cr>
