let NERDTreeWinPos="left"
let NERDTreeMinimalUI = 1
let NERDTreeDirArrows = 1
let NERDTreeShowBookmarks = 0
let NERDTreeIgnore = ['node_modules', 'dist', 'es5', 'jsconfig.json', 'yarn.lock', '.git$']
let NERDTreeCascadeSingleChildDir=1
let NERDTreeQuitOnOpen = 0
let NERDTreeAutoDeleteBuffer = 1
let NERDTreeShowHidden = 1
let g:NERDTreeMapOpenSplit = "s"
let g:NERDTreeMapOpenVSplit = "v"

map <leader>no :let NERDTreeQuitOnOpen=!NERDTreeQuitOnOpen<cr>

function! IsNERDTreeOpen()
  return exists("t:NERDTreeBufName") && (bufwinnr(t:NERDTreeBufName) != -1)
endfunction

let s:overwrote_NERDTreePathResolve = 0

function! NERDTreeFindOrDefault()
    if !exists("s:overwrote_NERDTreePathResolve")
        let s:overwrote_NERDTreePathResolve = 1

        function! g:NERDTreePath.Resolve(path)
            let tmp = resolve(a:path)
            if tmp =~ "floatjs/common"
                let tmp = substitute(tmp, "floatjs/common", "floatjs/web/_common", "")
            endif
            return tmp =~# '.\+/$' ? substitute(tmp, '/$', '', '') : tmp
        endfunction
    endif

    try
        NERDTreeFind
    catch /.*/
    endtry

    if !IsNERDTreeOpen()
        NERDTree
    endif
endfunction

map <silent> <leader>g :call NERDTreeFindOrDefault()<cr>
