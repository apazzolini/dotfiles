let NERDTreeMinimalUI = 1
let NERDTreeDirArrows = 1
let NERDTreeShowBookmarks = 0
let NERDTreeIgnore = ['node_modules', 'dist', 'es5', 'build', 'jsconfig.json']
let NERDTreeCascadeSingleChildDir=1
let NERDTreeQuitOnOpen = 0
let NERDTreeAutoDeleteBuffer = 1
let NERDTreeShowHidden=0
let g:NERDTreeMapOpenSplit="s"
let g:NERDTreeMapOpenVSplit="v"
map <leader>g :NERDTreeFind<cr>

map <leader>no :let NERDTreeQuitOnOpen=!NERDTreeQuitOnOpen<cr>
map <leader>nO :NERDTree<cr>

autocmd StdinReadPre * let g:isReadingFromStdin = 1
autocmd VimEnter * if !argc() && !exists('g:isReadingFromStdin') | NERDTree | endif
