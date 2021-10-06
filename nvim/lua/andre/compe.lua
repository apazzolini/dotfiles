if pcall(require, 'compe') then
  require('compe').setup({
    enabled = true,
    autocomplete = true,
    debug = false,
    min_length = 0,
    preselect = 'disable',
    throttle_time = 80,
    source_timeout = 400,
    incomplete_delay = 400,
    max_abbr_width = 40,
    max_kind_width = 40,
    max_menu_width = 40,
    documentation = true,

    source = {
      path = false,
      buffer = {
        priority = 5,
      },
      calc = false,
      nvim_lsp = {
        priority = 10,
        dup = false,
      },
      nvim_lua = {
        priority = 10,
      },
      vsnip = false,
      treesitter = false,
    },
  })

  local t = function(str)
    return vim.api.nvim_replace_termcodes(str, true, true, true)
  end

  local check_back_space = function()
    local col = vim.fn.col('.') - 1
    if col == 0 or vim.fn.getline('.'):sub(col, col):match('%s') then
      return true
    else
      return false
    end
  end

  _G.tab_complete = function()
    if vim.fn.call('neosnippet#expandable_or_jumpable', {}) == 1 then
      return t('<Plug>(neosnippet_expand_or_jump)')
    elseif vim.fn.pumvisible() == 1 then
      return t('<C-n>')
    elseif check_back_space() then
      return t('<Tab>')
    else
      return vim.fn['compe#complete']()
    end
  end

  vim.api.nvim_set_keymap('i', '<Tab>', 'v:lua.tab_complete()', { expr = true })
  vim.api.nvim_set_keymap('i', '<S-Tab>', t('pumvisible() ? "<C-p>" : "<S-TAB>"'), { expr = true })
  vim.api.nvim_set_keymap('i', '<c-j>', t('pumvisible() ? "<C-n>" : "<c-j>"'), { expr = true })
  vim.api.nvim_set_keymap('i', '<c-k>', t('pumvisible() ? "<C-p>" : "<c-k>"'), { expr = true })
  vim.api.nvim_set_keymap('i', '<c-space>', 'compe#complete()', { expr = true })
end
