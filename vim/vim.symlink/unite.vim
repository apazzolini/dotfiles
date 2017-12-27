let g:unite_source_rec_max_cache_files = 0
let g:unite_source_rec_async_command = ['rg', '--follow', '--color=never', 
    \ '-g', '*.*', 
    \ '-g', 'config/local.js', 
    \ '-g', '!.git',  
    \ '-g', '!es5', 
    \ '-g', '!dist', 
    \ '-g', '!*/__fixtures__/*', 
    \ '-g', '!*/__snapshots__/*',
    \ '-g', '!tmux.symlink/resurrect*',
    \ '-g', '!tmux.symlink/plugins',
    \ '-g', '!vim.symlink/plugged',
    \ '-g', '!.DS_Store',
    \ '--files' ]

nnoremap <leader>b :<C-u>Unite -no-split -buffer-name=buffer buffer<cr>

nnoremap <leader>t :<C-u>Unite -no-split -buffer-name=files -start-insert -default-action=tabopen file_rec/async<cr>
nnoremap <leader>s :<C-u>Unite -no-split -buffer-name=files -start-insert -default-action=split file_rec/async<cr>
nnoremap <leader>v :<C-u>Unite -no-split -buffer-name=files -start-insert -default-action=vsplit file_rec/async<cr>
nnoremap <leader>e :<C-u>Unite -no-split -buffer-name=files -start-insert file_rec/async<cr>

nnoremap <leader>T :<C-u>Unite -no-split -buffer-name=files -start-insert -input=`expand('%:h').'/ '` -default-action=tabopen file_rec/async<cr>
nnoremap <leader>S :<C-u>Unite -no-split -buffer-name=files -start-insert -input=`expand('%:h').'/ '` -default-action=split file_rec/async<cr>
nnoremap <leader>V :<C-u>Unite -no-split -buffer-name=files -start-insert -input=`expand('%:h').'/ '` -default-action=vsplit file_rec/async<cr>
nnoremap <leader>E :<C-u>Unite -no-split -buffer-name=files -start-insert -input=`expand('%:h').'/ '` file_rec/async<cr>

autocmd FileType unite call s:unite_settings()
function! s:unite_settings()
  nmap <buffer> <Space> 10j
  nmap <buffer> <BS>    10k
  imap <buffer> <C-c>   <esc>q
  imap <buffer> <C-k>   <Plug>(unite_select_previous_line)
  imap <buffer> <C-j>   <Plug>(unite_select_next_line)
endfunction
