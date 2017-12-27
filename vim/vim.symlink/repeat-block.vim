function! s:repeat_block(key) abort
  if a:key ==# '.'
    return get(s:, 'v_repeat_count', '').get(s:, 'v_repeat_key', '')
  endif

  let s:v_repeat_count = v:count1
  let s:v_repeat_key = a:key
  return a:key
endfunction

for k in ['w', 'W', 's', 'p', '[', ']', '(', ')', 'b', '<', '>', 't', '{', '}', 'B', '"', "'"]
  execute printf('vnoremap <expr> a%s <sid>repeat_block("a%s")', k, k)
  execute printf('vnoremap <expr> i%s <sid>repeat_block("i%s")', k, k)
endfor

unlet! k

vnoremap <expr> . <sid>repeat_block('.')
