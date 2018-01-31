let g:neoformat_try_formatprg = 1     " Use formatprg when available
let g:neoformat_only_msg_on_error = 1 " https://github.com/sbdchd/neoformat/issues/25

autocmd FileType css setlocal formatprg=prettier_dnc\ --parser\ postcss\ --local-only\ --pkg-conf\ --fallback
autocmd BufWritePre *.css Neoformat
