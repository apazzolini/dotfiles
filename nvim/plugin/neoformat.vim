" prettier_d_slim requires globally installing my forked version of the project
let g:neoformat_javascript_prettier = {
            \ 'exe': 'prettier_d_slim',
            \ 'args': ['--stdin', '--stdin-filepath', '"%:p"'],
            \ 'stdin': 1,
            \ }
let g:neoformat_typescript_prettier = g:neoformat_javascript_prettier
let g:neoformat_typescriptreact_prettier = g:neoformat_javascript_prettier

let g:neoformat_enabled_javascript = ['prettier']
let g:neoformat_enabled_typescript = ['prettier']
let g:neoformat_enabled_typescriptreact = ['prettier']

augroup fmt
  autocmd!
  " autocmd BufWritePre * undojoin | Neoformat
  autocmd BufWritePre * Neoformat
augroup END
