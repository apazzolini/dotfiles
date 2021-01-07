" prettier_d_slim requires globally installing my forked version of the project
let g:neoformat_javascriptreact_prettier = {
            \ 'exe': 'prettier_d_slim',
            \ 'args': ['--stdin', '--stdin-filepath', '"%:p"'],
            \ 'stdin': 1,
            \ }

let g:neoformat_enabled_javascriptreact = ['prettier']

augroup fmt
  autocmd!
  autocmd BufWritePre * undojoin | Neoformat
augroup END
