let g:unite_source_rec_async_command = ['ag', '--follow', '--nocolor', '--nogroup', '--hidden', '-g', '']
nnoremap <leader>t :<C-u>Unite -no-split -buffer-name=files -start-insert -default-action=tabopen file_rec/git<cr>
nnoremap <leader>s :<C-u>Unite -no-split -buffer-name=files -start-insert -default-action=split file_rec/git<cr>
nnoremap <leader>v :<C-u>Unite -no-split -buffer-name=files -start-insert -default-action=vsplit file_rec/git<cr>
nnoremap <leader>e :<C-u>Unite -no-split -buffer-name=files -start-insert file_rec/git<cr>
nnoremap <leader>b :<C-u>Unite -no-split -buffer-name=buffer  buffer<cr>

let g:unite_source_grep_command = 'ag'
let g:unite_source_grep_default_opts = '--nocolor --nogroup --column'
nmap <leader>a :Unite -no-quit -winheight=10 -direction=dynamicbottom grep:.<cr>

autocmd FileType unite call s:unite_settings()
function! s:unite_settings()
  nmap <buffer> <Space> 10j
  nmap <buffer> <BS>    10k
  imap <buffer> <C-j>   <Plug>(unite_select_next_line)
  imap <buffer> <C-k>   <Plug>(unite_select_previous_line)
  nmap <buffer> <C-j>   <Plug>(unite_select_next_line)
  nmap <buffer> <C-k>   <Plug>(unite_select_previous_line)
  nmap <silent><buffer><expr> V     unite#do_action('vsplit')
  nmap <silent><buffer><expr> I     unite#do_action('split')
endfunction

