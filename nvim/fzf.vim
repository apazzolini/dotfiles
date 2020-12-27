command! -bang -nargs=* Rg
  \ call fzf#vim#grep(
  \   'rg --smart-case --column --line-number --no-heading --color=always --follow ' . $RG_GLOBS . ' ' . <q-args>, 1,
  \   <bang>0 ? fzf#vim#with_preview('up:60%')
  \           : fzf#vim#with_preview('right:50%:hidden', '?'),
  \   <bang>0)

nnoremap <leader>b :Buffers<cr>

nnoremap <leader>e :call fzf#run({'sink': 'edit', 'window': 'call FloatingFZF()'})<cr>
nnoremap <leader>t :call fzf#run({'sink': 'tabedit', 'window': 'call FloatingFZF()'})<cr>
nnoremap <leader>s :call fzf#run({'sink': 'split', 'window': 'call FloatingFZF()'})<cr>
nnoremap <leader>v :call fzf#run({'sink': 'vsplit', 'window': 'call FloatingFZF()'})<cr>

nnoremap <leader>E :call fzf#run({'dir': expand('%:h'), 'sink': 'edit', 'window': 'call FloatingFZF()'})<cr>
nnoremap <leader>T :call fzf#run({'dir': expand('%:h'), 'sink': 'tabedit', 'window': 'call FloatingFZF()'})<cr>
nnoremap <leader>S :call fzf#run({'dir': expand('%:h'), 'sink': 'split', 'window': 'call FloatingFZF()'})<cr>
nnoremap <leader>V :call fzf#run({'dir': expand('%:h'), 'sink': 'vsplit', 'window': 'call FloatingFZF()'})<cr>

nnoremap <leader>a :Rg!<space>

let g:fzf_layout = { 'window': 'call FloatingFZF()' }

function! FloatingFZF()
  let buf = nvim_create_buf(v:false, v:true)
  call setbufvar(buf, '&signcolumn', 'no')

  let height = float2nr(&lines / 2)
  let width = float2nr(&columns - (&columns * 2 / 10))
  let col = float2nr((&columns - width) / 2)

  let opts = {
        \ 'relative': 'editor',
        \ 'row': 1,
        \ 'col': col,
        \ 'width': width,
        \ 'height': height
        \ }

  call nvim_open_win(buf, v:true, opts)
endfunction

highlight NormalFloat cterm=NONE ctermfg=14 ctermbg=0 gui=NONE guifg=#93a1a1 guibg=#002931
autocmd! FileType fzf
autocmd  FileType fzf setlocal nonumber nornu

function! s:list_buffers()
  redir => list
  silent ls
  redir END
  return split(list, "\n")
endfunction

function! s:delete_buffers(lines)
  execute 'bwipeout' join(map(a:lines, {_, line -> split(line)[0]}))
endfunction

command! BD call fzf#run(fzf#wrap({
  \ 'source': s:list_buffers(),
  \ 'sink*': { lines -> s:delete_buffers(lines) },
  \ 'options': '--multi --reverse --bind ctrl-a:select-all+accept'
\ }))

nnoremap <leader>B :BD<cr>
nnoremap <leader>W :Rg! <c-r><c-w><cr>
