setlocal colorcolumn=
setlocal winheight=10

map <buffer> q :q<cr>
map <buffer> dd :.Reject<cr>
xmap <buffer> d :'<,'>Reject<cr>
map <buffer> <s-j> j<cr><c-w><c-w>
map <buffer> <s-k> k<cr><c-w><c-w>
map <buffer> <cr> <cr>
