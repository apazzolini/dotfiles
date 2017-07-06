let g:unite_source_rec_async_command = ['rg', '--follow', '--color=never', '-g', 'config/local.js', '-g', '*.*', '-g', '!.git', '--files']
nnoremap <leader>t :<C-u>Unite -no-split -buffer-name=files -start-insert -default-action=tabopen file_rec/async<cr>
nnoremap <leader>s :<C-u>Unite -no-split -buffer-name=files -start-insert -default-action=split file_rec/async<cr>
nnoremap <leader>v :<C-u>Unite -no-split -buffer-name=files -start-insert -default-action=vsplit file_rec/async<cr>
nnoremap <leader>e :<C-u>Unite -no-split -buffer-name=files -start-insert file_rec/async<cr>
nnoremap <leader>b :<C-u>Unite -no-split -buffer-name=buffer buffer<cr>

autocmd FileType unite call s:unite_settings()
function! s:unite_settings()
  nmap <buffer> <Space> 10j
  nmap <buffer> <BS>    10k
endfunction
