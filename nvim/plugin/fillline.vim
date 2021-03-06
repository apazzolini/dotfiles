" Fill rest of line with characters
" http://stackoverflow.com/questions/3364102/how-to-fill-a-line-with-character-x-up-to-column-y-using-vim
function! FillLine( str )
  let tw = &colorcolumn
  if (!tw)
    let tw = 81
  endif
  let tw = tw - 1
  echo tw
  .s/[[:space:]]*$//
  let reps = (tw - col("$")) / len(a:str)

  if col("$") == 1 || getline('.')[col('$')-2] == a:str
      let start = ''
      let reps = reps + 1
  else
      let start = ' '
  endif

  if reps > 0
    .s/$/\=(start . repeat(a:str, reps))/
  endif
endfunction

map <leader>L :call FillLine( '-' )<CR>
