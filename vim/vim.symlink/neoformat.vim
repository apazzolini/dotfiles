let g:neoformat_try_formatprg = 1     " Use formatprg when available
let g:neoformat_only_msg_on_error = 1 " https://github.com/sbdchd/neoformat/issues/25

autocmd FileType css setlocal formatprg=prettier_dnc\ --parser\ postcss\ --local-only\ --pkg-conf\ --fallback
" autocmd BufWritePre *.css Neoformat

autocmd FileType javascript setlocal formatprg=prettier_dnc\ --local-only\ --fallback\ --parser\ flow\ --trailing-comma\ all\ --single-quote\ --pkg-conf
autocmd FileType javascript.jsx setlocal formatprg=prettier_dnc\ --local-only\ --fallback\ --parser\ flow\ --trailing-comma\ all\ --single-quote\ --pkg-conf
" autocmd BufWritePre *.js Neoformat
" autocmd BufWritePre *.jsx Neoformat
