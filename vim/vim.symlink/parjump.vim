function! ParJump(dir, ...)
  " Description: Paragraph jumping to land on non-blank lines
  " Arguments:
  "   dir = 1 : Search forward  for the last  line of the current paragraph or first line of the next one
  "         0 : Search backward for the first line of the current paragraph or last  line of the next one
  "   a:1     : Output of visualmode()
  " TODO:
  " * Cursor doesn't stay in the same column in Visual mode

  let l:curr_line = line('.')
  let l:curr_col  = col('.')

  if (a:dir)
    if (  (len(getline(l:curr_line)) == 0)
     \ || (len(getline(l:curr_line + 1)) == 0)
     \ )
      " Current or next line is blank
      " ==> Find next non-blank line
      let l:targ_line = nextnonblank(l:curr_line + 1)
    else
      " Neither the current nor the next line is blank i.e. we're in the middle of a paragraph
      " ==> Jump to the last non-blank line
      let l:targ_line = search('^$', 'nW')
      let l:targ_line = (l:targ_line > 0 ? l:targ_line - 1 : line('$'))
    endif
  else
    if (  (len(getline(l:curr_line)) == 0)
     \ || (len(getline(l:curr_line - 1)) == 0)
     \ )
      let l:targ_line = prevnonblank(l:curr_line - 1)
    else
      let l:targ_line = search('^$', 'nWb')
      let l:targ_line = (l:targ_line > 0 ? l:targ_line + 1 : 1)
    endif
  endif

  call setpos((a:0 ? "'>" : "."), [0, l:targ_line, l:curr_col])
  if a:0
    normal! gv
  endif
endfunction


nnoremap <silent> [ :call ParJump(0)<CR>^
nnoremap <silent> ] :call ParJump(1)<CR>^
vnoremap <silent> [ :call ParJump(0, visualmode())<CR>
vnoremap <silent> ] :call ParJump(1, visualmode())<CR>
