let g:ackprg = 'ag --nogroup --nocolor --column'
let g:ack_mappings = { "v": "<C-w><CR><C-w>L<C-w>h<C-w>j<C-w>J<C-w>10_<C-w>k<C-w>l<C-w>l" }

"let g:ack_mappings = {
  "\  'v': '<C-W><CR><C-W>L<C-W>p<C-W>J<C-W>p',
  "\ 'gv': '<C-W><CR><C-W>L<C-W>p<C-W>J' }

nmap <leader>a :Ack!<space>''<left>
nmap <leader>c :Ack!<CR>
nmap <D-F> :Ack!<space>''<left>

