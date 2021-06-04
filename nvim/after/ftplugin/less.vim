augroup lessfmt
  autocmd!
  autocmd BufWritePre *.less lua vim.lsp.buf.formatting_sync(nil, 2000)
augroup END
