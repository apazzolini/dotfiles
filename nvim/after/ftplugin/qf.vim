setlocal colorcolumn=
setlocal winheight=10

" https://stackoverflow.com/questions/42905008/quickfix-list-how-to-add-and-remove-entries
" When using `dd` in the quickfix list, remove the item from the quickfix list.
if !exists('*RemoveQFItem')
  function! RemoveQFItem()
    let curqfidx = line('.') - 1
    let qfall = getqflist()
    call remove(qfall, curqfidx)
    call setqflist(qfall, 'r')
    execute curqfidx + 1 . "cfirst"
    :copen
  endfunction
endif

map <buffer> q :q<cr>
map <buffer> dd :call RemoveQFItem()<cr>
map <buffer> <s-j> j<cr><c-w><c-w>
map <buffer> <s-k> k<cr><c-w><c-w>
map <buffer> <cr> <cr>
