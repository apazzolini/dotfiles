return {
  {
    'hrsh7th/nvim-cmp',
    cond = vim.g.isNotes == false,
    lazy = false,
    priority = 100,
    dependencies = {
      'onsails/lspkind.nvim',
      'hrsh7th/cmp-nvim-lsp',
      'hrsh7th/cmp-buffer',
      'hrsh7th/cmp-path',
      { 'L3MON4D3/LuaSnip', build = 'make install_jsregexp' },
      'saadparwaiz1/cmp_luasnip',
    },
    config = function()
      local cmp = require('cmp')
      local luasnip = require('luasnip')

      local has_words_before = function()
        if vim.api.nvim_buf_get_option(0, 'buftype') == 'prompt' then
          return false
        end
        local line, col = unpack(vim.api.nvim_win_get_cursor(0))
        return col ~= 0 and vim.api.nvim_buf_get_lines(0, line - 1, line, true)[1]:sub(col, col):match('%s') == nil
      end

      -- Temporary workaround for holding <cr> in a lua file
      -- https://github.com/hrsh7th/nvim-cmp/issues/1797
      local function fast_cmp_visible()
        if not (cmp.core.view and cmp.core.view.custom_entries_view) then
          return false
        end
        return cmp.core.view.custom_entries_view:visible()
      end
      local function try_accept_completion(key)
        return cmp.mapping(function(fallback)
          if fast_cmp_visible() and cmp.get_active_entry() then
            local entry = cmp.get_active_entry()
            cmp.confirm()
          else
            fallback()
          end
        end, { 'i', 'c' })
      end

      cmp.setup({
        preselect = cmp.PreselectMode.None,
        snippet = {
          expand = function(args)
            luasnip.lsp_expand(args.body)
          end,
        },
        mapping = {
          ['<C-u>'] = cmp.mapping.scroll_docs(-4),
          ['<C-d>'] = cmp.mapping.scroll_docs(4),
          ['<C-Space>'] = cmp.mapping.complete({}),

          -- See above
          -- ['<CR>'] = cmp.mapping.confirm({ select = false }),
          ['<CR>'] = try_accept_completion('<cr>'),

          ['<C-j>'] = cmp.mapping.select_next_item({ 'i', 'c' }),
          ['<C-k>'] = cmp.mapping.select_prev_item({ 'i', 'c' }),
          ['<Down>'] = cmp.mapping.select_next_item({ 'i', 'c' }),
          ['<Up>'] = cmp.mapping.select_prev_item({ 'i', 'c' }),
          ['<Tab>'] = cmp.mapping(function(fallback)
            if luasnip.expandable() then
              luasnip.expand()
              -- elseif cmp.visible() then
            elseif has_words_before() then
              cmp.select_next_item({ cmp.SelectBehavior.Insert })
              -- cmp.complete()
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
          {
            name = 'nvim_lsp',
            entry_filter = function(entry)
              return entry:get_filter_text():match('^SVG') == nil
            end,
          },
          -- { name = 'buffer', keyword_length = 5 },
          -- { name = 'path' },
        },
        window = {
          documentation = cmp.config.window.bordered(),
        },

        -- sorting = {
        --   priority_weight = 2.0,
        --   comparators = {
        --     -- cmp.config.compare.recently_used,
        --     cmp.config.compare.exact,
        --     cmp.config.compare.score, -- based on :  score = score + ((#sources - (source_index - 1)) * sorting.priority_weight)
        --     cmp.config.compare.offset,
        --     cmp.config.compare.locality,
        --     cmp.config.compare.kind,
        --     cmp.config.compare.length,
        --     cmp.config.compare.order,
        --   },
        -- },
      })

      for _, ft_path in ipairs(vim.api.nvim_get_runtime_file('lua/snippets/*.lua', true)) do
        loadfile(ft_path)()
      end
    end,
  },
}
