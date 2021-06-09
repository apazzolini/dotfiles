setlocal signcolumn=yes
setlocal winwidth=88
setlocal shiftwidth=2
setlocal tabstop=2
setlocal softtabstop=2

let b:pear_tree_pairs = extend(deepcopy(g:pear_tree_pairs), {
  \ '`'     : {'closer': '`'},
  \ '/\*\*' : {'closer': '\*/'},
  \ '<*>'   : {'closer': '</*>',
  \              'not_if': ['br', 'hr', 'img', 'input', 'link', 'meta',
  \                'area', 'base', 'col', 'command', 'embed',
  \                'keygen', 'param', 'source', 'track', 'wbr'
  \              ],
  \              'not_like': '{[^}]*$\|/$',
  \              'until': '[^a-zA-Z0-9-._]',
  \              'not_at': ['[^> ]<[^>]*'],
  \              'not_in': ['String']
  \           }
  \ }, 'keep')

" Old config before https://github.com/tmsvg/pear-tree/issues/31
"\              'not_like': '/$',
"\              'until': '[^a-zA-Z0-9-._]'

augroup tsxfmt
  autocmd!
  " autocmd BufWritePre * undojoin | Neoformat
  " autocmd BufWritePre * Neoformat
  autocmd BufWritePre *.tsx lua vim.lsp.buf.formatting_sync(nil, 2000)
augroup END
