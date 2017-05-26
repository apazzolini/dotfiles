" Fill rest of line with characters
" http://stackoverflow.com/questions/3364102/how-to-fill-a-line-with-character-x-up-to-column-y-using-vim
function! FillLine( str )
  let tw = 80
  .s/[[:space:]]*$//
  let reps = (tw - col("$")) / len(a:str)
  if reps > 0
    .s/$/\=(' '.repeat(a:str, reps))/
  endif
endfunction

map <leader>l :call FillLine( '-' )<CR>
