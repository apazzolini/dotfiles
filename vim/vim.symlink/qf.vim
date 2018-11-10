let g:qf_mapping_ack_style = 1

nmap <leader>> <Plug>qf_qf_previous
nmap <leader>. <Plug>qf_qf_next

" https://stackoverflow.com/questions/42905008/quickfix-list-how-to-add-and-remove-entries
" When using `dd` in the quickfix list, remove the item from the quickfix list.
function! RemoveQFItem()
  let curqfidx = line('.') - 1
  let qfall = getqflist()
  call remove(qfall, curqfidx)
  call setqflist(qfall, 'r')
  execute curqfidx + 1 . "cfirst"
  :copen
endfunction
:command! RemoveQFItem :call RemoveQFItem()
" Use map <buffer> to only map dd in the quickfix window. Requires +localmap

autocmd! FileType qf map <buffer> q :q<cr>
autocmd FileType qf map <buffer> dd :RemoveQFItem<cr>
