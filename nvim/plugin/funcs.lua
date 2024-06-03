vim.keymap.set('n', '<leader>L', function()
  vim.cmd([[
    let tw = &colorcolumn
    if (!tw)
      let tw = 81
    endif
    let tw = tw - 1
    .s/[ ]*$//
    let reps = (tw - col("$"))

    if col("$") == 1 || getline('.')[col('$')-2] == '-'
        let start = ''
        let reps = reps + 1
    else
        let start = ' '
    endif

    if reps > 0
      .s/$/\=(start . repeat('-', reps))/
    endif
    noh
  ]])
end)

-- Close all hidden buffers
vim.api.nvim_create_user_command('BC', function()
  vim.cmd([[
    let open_buffers = []
    for i in range(tabpagenr('$'))
      call extend(open_buffers, tabpagebuflist(i + 1))
    endfor
    for num in range(1, bufnr("$") + 1)
      if buflisted(num) && index(open_buffers, num) == -1
        exec "bdelete ".num
      endif
    endfor
  ]])
end, {})

vim.keymap.set('n', '<leader>A', function()
  -- Lualine doesn't like the quotes in the caddexpr, so we'll clear
  -- the title when using this function to prevent it breaking.
  vim.cmd([[
    call setqflist([], 'a', {'title': ''})
    cadde expand("%") . ":" . line(".") .  ":" . getline(".")
    wincmd p
  ]])
end)

-- Smart indent when entering insert mode with i on empty lines
vim.cmd([[
  function! IndentWith(default)
    if len(getline('.')) == 0
      return "\"_cc"
    else
      return a:default
    endif
  endfunction
  nnoremap <expr> a IndentWith("a")
  nnoremap <expr> i IndentWith("i")
]])

-- Reload treesitter and LSP
vim.keymap.set('n', '<leader>k', function()
  vim.cmd([[
    write
    edit
    TSBufEnable highlight
    LspStop
    sleep 1
    LspStart
  ]])
end)

-- Format JSON
vim.cmd([[
  command! -range=% JSON set ft=json | <line1>,<line2>!jq
]])
