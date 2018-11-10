command! -bang -nargs=* Rg
  \ call fzf#vim#grep(
  \   'rg --smart-case --column --line-number --no-heading --color=always ' . $RG_GLOBS . ' ' . <q-args>, 1,
  \   <bang>0 ? fzf#vim#with_preview('up:60%')
  \           : fzf#vim#with_preview('right:50%:hidden', '?'),
  \   <bang>0)

nnoremap <leader>b :Buffers<cr>

nnoremap <leader>e :call fzf#run({'sink': 'edit', 'window': 'top 30new'})<cr>
nnoremap <leader>t :call fzf#run({'sink': 'tabedit', 'window': 'top 30new'})<cr>
nnoremap <leader>s :call fzf#run({'sink': 'split', 'window': 'top 30new'})<cr>
nnoremap <leader>v :call fzf#run({'sink': 'vsplit', 'window': 'top 30new'})<cr>

nnoremap <leader>E :call fzf#run({'dir': expand('%:h'), 'sink': 'edit', 'window': 'top 30new'})<cr>
nnoremap <leader>T :call fzf#run({'dir': expand('%:h'), 'sink': 'tabedit', 'window': 'top 30new'})<cr>
nnoremap <leader>S :call fzf#run({'dir': expand('%:h'), 'sink': 'split', 'window': 'top 30new'})<cr>
nnoremap <leader>V :call fzf#run({'dir': expand('%:h'), 'sink': 'vsplit', 'window': 'top 30new'})<cr>

nnoremap <leader>a :Rg!<space>
