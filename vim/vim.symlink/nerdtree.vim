let NERDTreeMinimalUI = 1
let NERDTreeDirArrows = 1
let NERDTreeShowBookmarks = 0
let NERDTreeIgnore = ['node_modules', 'dist', 'es5', 'build', 'jsconfig.json']
let NERDTreeCascadeSingleChildDir=1
let NERDTreeQuitOnOpen = 1
let NERDTreeAutoDeleteBuffer = 1
let NERDTreeShowHidden=0
let g:NERDTreeMapOpenSplit="s"
let g:NERDTreeMapOpenVSplit="v"
map <leader>g :NERDTreeFind<cr>

map <leader>no :let NERDTreeQuitOnOpen=!NERDTreeQuitOnOpen<cr>
