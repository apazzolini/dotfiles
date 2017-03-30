set shellpipe=>
"set t_ti= t_te=

let g:ackprg = 'ag --nogroup --nocolor --column'

let g:ack_mappings = {
    \ "t": "<C-W><CR><C-W>T",
    \ "T": "<C-W><CR><C-W>TgT<C-W>j",
    \ "o": "<CR>",
    \ "<cr>": "<CR>",
    \ "O": "<CR><C-W><C-W>:ccl<CR>",
    \ "go": "<CR><C-W>j",
    \ "h": "<C-W><CR><C-W>K",
    \ "H": "<C-W><CR><C-W>K<C-W>b",
    \ 'v':  '<C-W><CR><C-W>L<C-W>p<C-W>J:resize 10<cr><C-W>p',
    \ 'gv': '<C-W><CR><C-W>L<C-W>p<C-W>J:resize 10<cr>' }

nmap <leader>a :Ack!<space>''<left>
nmap <leader>A :Ack!<CR>

