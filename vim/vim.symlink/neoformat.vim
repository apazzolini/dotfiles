let g:neoformat_javascript_prettier = {
\ 'exe': './node_modules/.bin/prettier',
\ 'args': ['--stdin', '--print-width 110', '--tab-width 4', '--single-quote', '--trailing-comma es5'],
\ 'stdin': 1,
\ 'no_append': 1,
\ }

let g:neoformat_enabled_javascript = ['prettier']
