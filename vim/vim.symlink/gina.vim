call gina#custom#command#option('status', '--opener', 'tabnew')

call gina#custom#mapping#nmap(
      \ '/.*', 'o',
      \ '<Plug>(gina-diff-preview)'
      \)

call gina#custom#mapping#nmap(
      \ 'status', 'C',
      \ ':Gina commit<cr>'
      \)

function! WriteAndCloseGina()
    :silent wq
    :tabclose
endfunction

call gina#custom#mapping#nmap(
      \ 'commit', '<leader>w',
      \ ':call WriteAndCloseGina()<cr>'
      \)

call gina#custom#mapping#nmap(
      \ '/.*', 'q',
      \ ':quit<cr>'
      \)

augroup previewWindowPosition
   au!
   autocmd BufWinEnter * call PreviewWindowPosition()
augroup END

function! PreviewWindowPosition()
   if &previewwindow
      wincmd L
   endif
endfunction

nmap <leader>G :Gstatus<cr>

set diffopt+=vertical
