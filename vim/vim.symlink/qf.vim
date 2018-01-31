let g:qf_mapping_ack_style = 1

nmap <leader>> <Plug>qf_qf_previous
nmap <leader>. <Plug>qf_qf_next

autocmd! FileType qf map <buffer> q :q<cr>
