let g:flog_default_arguments = {
  \ 'max_count': 1000,
  \ 'all': 0,
  \ }

" ------------------------------------------------------------------------------

let g:flog_horizontal = 0

" Removes flog_term state from flog and closes terminal buffer if it's open
function! flog#delete_flog_term()
  let l:state = flog#get_state()
  let l:termbufnr = get(l:state, 'termbufnr', 0)

  if l:termbufnr
    try
      execute('bdelete! ' . l:termbufnr)
    catch
    endtry
  endif

  let l:state.termbufnr = 0
endfunction

" Closes terminal buffer if it's open, otherwise closes flog
function! flog#smart_quit()
  let l:state = flog#get_state()
  let l:termbufnr = get(l:state, 'termbufnr', 0)
  if l:termbufnr
    call flog#delete_flog_term()
  else
    tabclose
  endif
endfunction

" Opens a terminal buffer for the commit.
function! flog#diff_fancy()
  call flog#close_tmp_win() " Closes non-terminal tmp window
  call flog#delete_flog_term() " Closes terminal tmp window

  let l:state = flog#get_state()
  let l:commit = flog#get_commit_at_line(line('.')).short_commit_hash
  let l:previous_window_id = win_getid()

  let position = g:flog_horizontal ? 'bot' : 'vertical botright'
  let pager = g:flog_horizontal ? 'delta --side-by-side' : 'delta'
  execute position . ' new +set\ filetype=flog_term_diff'
  setlocal buftype=nofile bufhidden=wipe noswapfile nomodeline nonumber norelativenumber
  let l:state.termid = termopen('GIT_PAGER="' . pager . '" git -p show -m ' . l:commit)
  call cursor(1, 1)
  let l:state.termbufnr = winbufnr(win_getid())

  call win_gotoid(l:previous_window_id)
endfunction

function! flog#fancy_next_commit() abort
  let l:state = flog#get_state()
  let l:termbufnr = get(l:state, 'termbufnr', 0)
  call flog#next_commit()
  if l:termbufnr
    call flog#diff_fancy()
  endif
endfunction

function! flog#fancy_prev_commit() abort
  let l:state = flog#get_state()
  let l:termbufnr = get(l:state, 'termbufnr', 0)
  call flog#previous_commit()
  if l:termbufnr
    call flog#diff_fancy()
  endif
endfunction

augroup MyFlogGroup
  autocmd!
  autocmd FileType floggraph set colorcolumn=
  autocmd FileType floggraph nnoremap <buffer> <silent> r :let g:flog_horizontal=!g:flog_horizontal<cr>
  autocmd FileType floggraph nnoremap <buffer> <silent> o :call flog#diff_fancy()<CR>
  autocmd FileType floggraph nnoremap <buffer> <silent> j :call flog#fancy_next_commit()<CR>
  autocmd FileType floggraph nnoremap <buffer> <silent> k :call flog#fancy_prev_commit()<CR>
  autocmd FileType floggraph nnoremap <buffer> <silent> q :call flog#smart_quit()<CR>
  autocmd FileType flog_term_diff nnoremap <buffer> <silent> q :wincmd p <bar> call flog#smart_quit()<CR>
augroup END
