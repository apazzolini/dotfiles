-- if not pcall(require, 'cmp') or pcall(require, 'luasnip') then
--   return
-- end

local cmp = require('cmp')
local luasnip = require('luasnip')

local has_words_before = function()
  if vim.api.nvim_buf_get_option(0, 'buftype') == 'prompt' then
    return false
  end
  local line, col = unpack(vim.api.nvim_win_get_cursor(0))
  return col ~= 0 and vim.api.nvim_buf_get_lines(0, line - 1, line, true)[1]:sub(col, col):match('%s') == nil
end

cmp.setup({
  preselect = cmp.PreselectMode.None,
  snippet = {
    expand = function(args)
      luasnip.lsp_expand(args.body)
    end,
  },
  mapping = {
    ['<C-d>'] = cmp.mapping.scroll_docs(-4),
    ['<C-f>'] = cmp.mapping.scroll_docs(4),
    ['<C-Space>'] = cmp.mapping.complete(),
    ['<CR>'] = cmp.mapping.confirm({ select = true }),
    ['<C-j>'] = cmp.mapping.select_next_item({ 'i', 'c' }),
    ['<C-k>'] = cmp.mapping.select_prev_item({ 'i', 'c' }),
    ['<Down>'] = cmp.mapping.select_next_item({ 'i', 'c' }),
    ['<Up>'] = cmp.mapping.select_prev_item({ 'i', 'c' }),
    ['<Tab>'] = cmp.mapping(function(fallback)
      if luasnip.expand_or_jumpable() then
        luasnip.expand_or_jump()
      elseif cmp.visible() then
        cmp.select_next_item({ cmp.SelectBehavior.Insert })
      elseif has_words_before() then
        cmp.complete()
      else
        fallback() -- The fallback function sends a already mapped key. In this case, it's probably `<Tab>`.
      end
    end, {
      'i',
      's',
    }),
    ['<S-Tab>'] = cmp.mapping(function(fallback)
      if luasnip.jumpable(-1) then
        luasnip.jump(-1)
      elseif cmp.visible() then
        cmp.select_prev_item({ cmp.SelectBehavior.Insert })
      else
        fallback()
      end
    end, {
      'i',
      's',
    }),
  },
  sources = {
    { name = 'nvim_lsp' },
    { name = 'buffer', keyword_length = 5 },
    { name = 'path' },
  },
  -- experimental = {
  -- native_menu = false,
  -- ghost_text = false,
  -- },
})

vim.cmd([[
  augroup NvimCmp
    au!
    au FileType TelescopePrompt lua require('cmp').setup.buffer { enabled = false }
  augroup END
]])
