highlight Normal guibg=#1C2023 guifg=#C7CCD1
highlight VertSplit guifg=#3f3642 guibg=#3f3642
set fillchars=eob:\ " Blank comment - just want a blank fillchar

let $FZF_DEFAULT_COMMAND='rg --color=never --files --hidden --smart-case --follow -g "*.*" -g "config/local.js" -g "!.git" -g "!es5" -g "!dist" -g "!.next" -g "!build" -g "!**/__fixtures__/**" -g "!**/__snapshots__/**" -g "!tmux.symlink/resurrect*" -g "!tmux.symlink/plugins" -g "!vim.symlink/plugged" -g "!yarn.lock" -g "!.DS_Store" -g "!.cache" -g "!*/vim.symlink/plugged" -g "!*/tmux.symlink/plugins"'
let $FZF_DEFAULT_OPTS='--reverse --no-bold --border --bind=ctrl-d:half-page-down,ctrl-u:half-page-up,ctrl-j:down,ctrl-k:up'

let g:fzf_colors =
\ { 'fg':      ['fg', 'Normal'],
  \ 'bg':      ['bg', 'Normal'],
  \ 'hl':      ['fg', 'Comment'],
  \ 'fg+':     ['fg', 'CursorLine', 'CursorColumn', 'Normal'],
  \ 'bg+':     ['bg', 'CursorLine', 'CursorColumn'],
  \ 'hl+':     ['fg', 'Statement'],
  \ 'info':    ['fg', 'PreProc'],
  \ 'border':  ['fg', 'Ignore'],
  \ 'prompt':  ['fg', 'Conditional'],
  \ 'pointer': ['fg', 'Exception'],
  \ 'marker':  ['fg', 'Keyword'],
  \ 'spinner': ['fg', 'Label'],
  \ 'header':  ['fg', 'Comment'] }

    nnoremap <D-[> :tabp<CR>
    vnoremap <D-[> :tabp<CR>
    inoremap <D-[> :tabp<CR>
    nnoremap <D-]> :tabn<CR>
    vnoremap <D-]> :tabn<CR>
    inoremap <D-]> :tabn<CR>

    tnoremap <D-[> <c-\><c-n>:tabp<CR>
    tnoremap <D-]> <c-\><c-n>:tabn<CR>

    map <D-/> ,c<space>

    let g:terminal_color_0 =  "#1C2023"
    let g:terminal_color_1 =  "#C7AE95"
    let g:terminal_color_2 =  "#95C7AE"
    let g:terminal_color_3 =  "#AEC795"
    let g:terminal_color_4 =  "#AE95C7"
    let g:terminal_color_5 =  "#C795AE"
    let g:terminal_color_6 =  "#95AEC7"
    let g:terminal_color_7 =  "#C7CCD1"
    let g:terminal_color_8 =  "#747C84"
    let g:terminal_color_9 =  "#C7AE95"
    let g:terminal_color_10 = "#95C7AE"
    let g:terminal_color_11 = "#AEC795"
    let g:terminal_color_12 = "#AE95C7"
    let g:terminal_color_13 = "#C795AE"
    let g:terminal_color_14 = "#95AEC7"
    let g:terminal_color_15 = "#F3F4F5"
    let g:terminal_color_background = g:terminal_color_0
    let g:terminal_color_foreground = g:terminal_color_5

    function! ClearTerminal()
        set scrollback=0
        call jobsend(b:terminal_job_id, "\<c-l>")
        redraw
        sleep 100m
        set scrollback=10000
        startinsert
    endfunction

    tnoremap <d-k> <c-\><c-n>:call ClearTerminal()<cr>
    tnoremap <c-;> <C-\><C-n>
    tnoremap <d-j> <C-\><C-n>
    tnoremap <c-h> <C-\><C-n><c-w>h
    tnoremap <expr> <c-j> &filetype == 'fzf' ? "\<c-j>" : "\<c-\>\<c-n>\<c-w>j"
    tnoremap <expr> <c-k> &filetype == 'fzf' ? "\<c-k>" : "\<c-\>\<c-n>\<c-w>k"
    " tnoremap <c-j> <C-\><C-n><c-w>j
    " tnoremap <c-k> <C-\><C-n><c-w>k
    tnoremap <c-l> <C-\><C-n><c-w>l
    tnoremap <d-w> <C-\><C-n>:q!<cr>
    " autocmd BufWinEnter,WinEnter term://* startinsert
    autocmd BufEnter * if &buftype == 'terminal' | :startinsert | endif
    " autocmd BufLeave term://* stopinsert

    augroup TerminalStuff
        au!
        autocmd TermOpen * setlocal nonumber norelativenumber
    augroup END



