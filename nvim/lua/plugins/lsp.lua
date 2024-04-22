local function get_lsp_completion_context(completion, source)
  local ok, source_name = pcall(function()
    return source.source.client.config.name
  end)
  if not ok then
    return nil
  end

  if source_name == 'tsserver' then
    return completion.detail
  elseif source_name == 'pyright' and completion.labelDetails ~= nil then
    return completion.labelDetails.description
  elseif source_name == 'texlab' then
    return completion.detail
  elseif source_name == 'clangd' then
    local doc = completion.documentation
    if doc == nil then
      return
    end

    local import_str = doc.value

    local i, j = string.find(import_str, '["<].*[">]')
    if i == nil then
      return
    end

    return string.sub(import_str, i, j)
  end
end

return {
  cond = vim.g.isNotes == false,
  'hrsh7th/nvim-cmp',
  dependencies = {
    'onsails/lspkind.nvim',
    'hrsh7th/cmp-nvim-lsp',
    'hrsh7th/cmp-buffer',
    'hrsh7th/cmp-path',
    'windwp/nvim-autopairs',
    {
      'L3MON4D3/LuaSnip',
      dependencies = {
        'saadparwaiz1/cmp_luasnip',
      },
    },
    'neovim/nvim-lspconfig',
    'williamboman/mason.nvim',
    {
      'nvimtools/none-ls.nvim',
      commit = 'bb680d752cec37949faca7a1f509e2fe67ab418a',
    },
    'folke/neodev.nvim',
    {
      'j-hui/fidget.nvim',
      opts = {
        progress = {
          suppress_on_insert = true,
          ignore_done_already = true,
          ignore = { 'null-ls', 'lua_ls' },
          display = {
            done_style = 'DiagnosticWarn',
            icon_style = 'DiagnosticWarn',
            group_style = 'DiagnosticWarn',
            progress_style = 'DiagnosticWarn',
            done_ttl = 0,
          },
        },
        notification = {
          window = {
            winblend = 0,
            normal_hl = 'DiagnosticWarn',
          },
          view = {
            group_separator_hl = 'DiagnosticWarn',
          },
        },
      },
    },
  },
  config = function()
    require('neodev').setup({
      override = function(_, options)
        options.enabled = true
        options.plugins = true
        options.types = true
        options.runtime = true
      end,
    })
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
        ['<C-u>'] = cmp.mapping.scroll_docs(-4),
        ['<C-d>'] = cmp.mapping.scroll_docs(4),
        ['<C-Space>'] = cmp.mapping.complete({}),
        ['<CR>'] = cmp.mapping.confirm({ select = false }),
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
        { name = 'buffer', keyword_length = 5 },
        { name = 'path' },
      },
      window = {
        documentation = cmp.config.window.bordered(),
      },

      -- From TJ
      -- sorting = {
      --   comparators = {
      --     cmp.config.compare.offset,
      --     cmp.config.compare.exact,
      --     cmp.config.compare.score,

      --     -- copied from cmp-under, but I don't think I need the plugin for this.
      --     -- I might add some more of my own.
      --     function(entry1, entry2)
      --       local _, entry1_under = entry1.completion_item.label:find('^_+')
      --       local _, entry2_under = entry2.completion_item.label:find('^_+')
      --       entry1_under = entry1_under or 0
      --       entry2_under = entry2_under or 0
      --       if entry1_under > entry2_under then
      --         return false
      --       elseif entry1_under < entry2_under then
      --         return true
      --       end
      --     end,

      --     cmp.config.compare.kind,
      --     cmp.config.compare.sort_text,
      --     cmp.config.compare.length,
      --     cmp.config.compare.order,
      --   },
      -- },

      -- From reddit
      sorting = {
        priority_weight = 1.0,
        comparators = {
          -- compare.score_offset, -- not good at all
          cmp.config.compare.locality,
          cmp.config.compare.recently_used,
          cmp.config.compare.score, -- based on :  score = score + ((#sources - (source_index - 1)) * sorting.priority_weight)
          cmp.config.compare.offset,
          cmp.config.compare.order,
          -- compare.scopes, -- what?
          -- compare.sort_text,
          -- compare.exact,
          -- compare.kind,
          -- compare.length, -- useless
        },
      },
      formatting = {
        fields = { 'kind', 'abbr', 'menu' },
        format = function(entry, vim_item)
          local ELLIPSIS_CHAR = '…'
          if not require('cmp.utils.api').is_cmdline_mode() then
            local abbr_width_max = 25
            local menu_width_max = 20

            local choice = require('lspkind').cmp_format({
              ellipsis_char = ELLIPSIS_CHAR,
              maxwidth = abbr_width_max,
              mode = 'symbol',
            })(entry, vim_item)

            choice.abbr = vim.trim(choice.abbr)
            choice.kind = choice.kind .. ' '

            -- give padding until min/max width is met
            -- https://github.com/hrsh7th/nvim-cmp/issues/980#issuecomment-1121773499
            local abbr_width = string.len(choice.abbr)
            if abbr_width < abbr_width_max then
              local padding = string.rep(' ', abbr_width_max - abbr_width)
              vim_item.abbr = choice.abbr .. padding
            end

            local cmp_ctx = get_lsp_completion_context(entry.completion_item, entry.source)
            if cmp_ctx ~= nil and cmp_ctx ~= '' then
              choice.menu = cmp_ctx
            else
              choice.menu = ''
            end

            local menu_width = string.len(choice.menu)
            if menu_width > menu_width_max then
              choice.menu = vim.fn.strcharpart(choice.menu, 0, menu_width_max - 1)
              choice.menu = choice.menu .. ELLIPSIS_CHAR
            else
              local padding = string.rep(' ', menu_width_max - menu_width)
              choice.menu = padding .. choice.menu
            end

            return choice
          else
            local abbr_width_min = 20
            local abbr_width_max = 50

            local choice = require('lspkind').cmp_format({
              ellipsis_char = ELLIPSIS_CHAR,
              maxwidth = abbr_width_max,
              mode = 'symbol',
            })(entry, vim_item)

            choice.abbr = vim.trim(choice.abbr)
            choice.kind = choice.kind .. ' '

            -- give padding until min/max width is met
            -- https://github.com/hrsh7th/nvim-cmp/issues/980#issuecomment-1121773499
            local abbr_width = string.len(choice.abbr)
            if abbr_width < abbr_width_min then
              local padding = string.rep(' ', abbr_width_min - abbr_width)
              vim_item.abbr = choice.abbr .. padding
            end

            return choice
          end
        end,
      },
    })

    require('nvim-autopairs').setup()

    -- If you want insert `(` after select function or method item
    -- local cmp_autopairs = require('nvim-autopairs.completion.cmp')
    -- local cmp = require('cmp')
    -- cmp.event:on('confirm_done', cmp_autopairs.on_confirm_done({ map_char = { tex = '' } }))

    ----------------------------------------------------------------------------

    require('andre.snippets')

    ----------------------------------------------------------------------------

    local log = require('vim.lsp.log')
    local util = require('vim.lsp.util')

    local orig_util_open_floating_preview = vim.lsp.util.open_floating_preview
    function vim.lsp.util.open_floating_preview(contents, syntax, opts, ...)
      opts = opts or {}
      opts.border = opts.border or 'rounded'
      return orig_util_open_floating_preview(contents, syntax, opts, ...)
    end

    local function close_floating()
      vim.cmd('noh')
      for _, win in ipairs(vim.api.nvim_list_wins()) do
        local config = vim.api.nvim_win_get_config(win)
        if config.relative ~= '' then
          vim.api.nvim_win_close(win, false)
        end
      end
    end

    vim.fn.sign_define('LspDiagnosticsSignError', { text = '>', texthl = 'LspDiagnosticsSignError', linehl = '', numhl = '' })
    vim.fn.sign_define('LspDiagnosticsSignWarning', { text = '>', texthl = 'LspDiagnosticsSignWarning', linehl = '', numhl = '' })
    vim.fn.sign_define('LspDiagnosticsSignInformation', { text = '>', texthl = 'LspDiagnosticsSignInformation', linehl = '', numhl = '' })
    vim.fn.sign_define('LspDiagnosticsSignHint', { text = '>', texthl = 'LspDiagnosticsSignHint', linehl = '', numhl = '' })

    local function set_lsp_keymaps(client, bufnr)
      local opts = { noremap = true, silent = true }

      vim.keymap.set('n', 'gd', '<cmd>lua vim.lsp.buf.definition()<cr>', opts)
      vim.keymap.set('n', 'gD', '<cmd>lua vim.lsp.buf.type_definition()<cr>zz', opts)
      vim.keymap.set('n', 'gI', '<cmd>lua vim.lsp.buf.implementation()<cr>zz', opts)
      vim.keymap.set('n', 'gr', '<cmd>lua vim.lsp.buf.references()<cr>', opts)
      vim.keymap.set('n', 'gh', '<cmd>lua vim.lsp.buf.hover()<cr>', opts)
      vim.keymap.set('n', '<cr>', close_floating, opts)
      vim.keymap.set('n', '<leader>ca', '<cmd>lua vim.lsp.buf.code_action()<cr>', opts)

      vim.keymap.set('n', '<leader>ci', function()
        vim.lsp.buf.code_action({
          apply = true,
          filter = function(ca)
            return ca.title:match('^Add import from') or ca.title:match('^Update import from')
          end,
        })
      end)

      local errorDiagnostics = '{ severity = ' .. vim.diagnostic.severity.ERROR .. ' }'
      vim.keymap.set('n', '<leader>m', '<cmd>lua vim.diagnostic.goto_prev(' .. errorDiagnostics .. ')<cr>zz', opts)
      vim.keymap.set('n', '<leader>.', '<cmd>lua vim.diagnostic.goto_next(' .. errorDiagnostics .. ')<cr>zz', opts)

      vim.keymap.set('n', 'gH', '<cmd>lua vim.diagnostic.open_float()<cr>')

      vim.keymap.set('n', '<leader>M', '<cmd>lua vim.diagnostic.goto_prev()<cr>zz', opts)
      vim.keymap.set('n', '<leader>>', '<cmd>lua vim.diagnostic.goto_next()<cr>zz', opts)

      vim.keymap.set('n', '<leader>le', '<cmd>lua vim.diagnostic.setqflist(' .. errorDiagnostics .. ')<cr>zz', opts)
      vim.keymap.set('n', '<leader>la', '<cmd>cexpr system("npm run lint -- --format unix") <bar> copen<cr>', opts)
      vim.keymap.set('n', '<leader>lf', '<cmd>%!eslint_d --stdin --fix-to-stdout --stdin-filename %<cr>', opts)

      vim.keymap.set('n', '<leader>F', '<cmd>lua vim.lsp.buf.format({ timeout_ms = 2000 })<cr>', opts)
    end

    local function format_on_save(bufnr)
      vim.api.nvim_create_autocmd({ 'BufWritePre' }, {
        callback = function()
          vim.lsp.buf.format({ timeout_ms = 2000 })
        end,
        buffer = bufnr,
      })
    end

    local function disable_semantic_tokens(client)
      if client and client.server_capabilities then
        client.server_capabilities.semanticTokensProvider = nil
      end
    end

    local function disable_formatting(client)
      if client and client.server_capabilities then
        client.server_capabilities.documentFormattingProvider = false
        client.server_capabilities.documentRangeFormattingProvider = false
      end
    end

    local function handler_publishDiagnostics(virtual_text_level, signs_error)
      return vim.lsp.with(vim.lsp.diagnostic.on_publish_diagnostics, {
        underline = false,
        virtual_text = {
          severity_limit = virtual_text_level,
        },
        update_in_insert = false,
        signs = {
          severity_limit = signs_error,
        },
      })
    end

    local function first_match(_, result, context)
      local method = context.method
      if result == nil or vim.tbl_isempty(result) then
        local _ = log.info() and log.info(method, 'No location found')
        return nil
      end

      local location = result
      if vim.tbl_islist(result) then
        location = result[1]
      end
      util.jump_to_location(location, vim.lsp.get_client_by_id(context.client_id).offset_encoding, false)

      vim.cmd('normal zz')
    end

    ----------------------------------------------------------------------------

    require('mason').setup({})
    local capabilities = require('cmp_nvim_lsp').default_capabilities()
    local capabilitiesWithoutSnippets = require('cmp_nvim_lsp').default_capabilities({ snippetSupport = false })
    local lspconfig = require('lspconfig')

    -- TSSERVER ----------------------------------------------------------------

    lspconfig.tsserver.setup({
      capabilities = capabilities,
      root_dir = function(fname)
        return lspconfig.util.root_pattern('pnpm-workspace.yaml')(fname)
          or lspconfig.util.root_pattern('.git')(fname)
          or lspconfig.util.root_pattern('package.json', 'jsconfig.json', 'tsconfig.json')(fname)
      end,
      single_file_support = false,
      init_options = {
        maxTsServerMemory = 6144,
        preferences = {
          importModuleSpecifierPreference = 'non-relative',
          includePackageJsonAutoImports = 'off',
        },
      },
      on_attach = function(client, bufnr)
        -- use prettier via efm on save instead of tsserver's builtin formatting
        disable_formatting(client)
        disable_semantic_tokens(client)
        set_lsp_keymaps(client, bufnr)
      end,
      flags = {
        debounce_text_changes = 200,
      },
      handlers = {
        ['textDocument/publishDiagnostics'] = handler_publishDiagnostics('Error', 'Warning'),
        ['textDocument/definition'] = first_match,
        ['textDocument/typeDefinition'] = first_match,
      },
    })

    -- JSONLS ------------------------------------------------------------------

    lspconfig.jsonls.setup({
      capabilities = capabilities,
      settings = {
        json = {
          schemas = require('schemastore').json.schemas(),
          validate = { enable = true },
        },
      },
      on_attach = function(client, bufnr)
        set_lsp_keymaps(client, bufnr)
        disable_formatting(client)
        disable_semantic_tokens(client)
      end,
      handlers = {
        ['textDocument/publishDiagnostics'] = function()
          return false
        end,
      },
    })

    -- ASTRO -------------------------------------------------------------------

    lspconfig.astro.setup({
      capabilities = capabilities,
      on_attach = function(client, bufnr)
        set_lsp_keymaps(client, bufnr)
        disable_formatting(client)
        disable_semantic_tokens(client)
      end,
    })

    -- RUST --------------------------------------------------------------------

    lspconfig.rust_analyzer.setup({
      capabilities = capabilities,
      on_attach = function(client, bufnr)
        set_lsp_keymaps(client, bufnr)
        format_on_save(bufnr)
        disable_semantic_tokens(client)
      end,
      cmd = { 'rustup', 'run', 'stable', 'rust-analyzer' },
    })

    -- LUA_LS ------------------------------------------------------------------

    lspconfig.lua_ls.setup({
      settings = {
        Lua = {
          workspace = {
            library = { '/Users/andre/GitHub/_forks/hammerspoon/build/stubs' },
            checkThirdParty = false,
          },
          telemetry = {
            enable = false,
          },
        },
      },
      on_attach = function(client, bufnr)
        disable_formatting(client)
        disable_semantic_tokens(client)
        set_lsp_keymaps(client, bufnr)
      end,
      handlers = {
        ['textDocument/definition'] = first_match,
      },
    })

    -- TAILWIND ----------------------------------------------------------------

    -- git clone https://github.com/apazzolini/tailwindcss-intellisense.git
    -- cd tailwindcss-intellisense
    -- git co andre/show-equivs
    -- npm i
    -- npm run bootstrap
    -- cd packages/tailwindcss-language-server
    -- NODE_OPTIONS=--openssl-legacy-provider npm run build
    -- npm i -g $(pwd)
    lspconfig.tailwindcss.setup({
      -- cmd = { 'node', '--inspect', '/usr/local/bin/tailwindcss-language-server', '--stdio' },
      settings = {
        tailwindCSS = {
          experimental = {
            classRegex = {
              'tw`([^`]*)',
              { 'classnames\\(([^)]*)\\)', "'([^']*)'" },
            },
          },
        },
      },
      handlers = {
        ['textDocument/hover'] = function(_, result, ctx, config)
          local bufnr, winnr = vim.lsp.handlers.hover(_, result, ctx, config)
          if bufnr ~= nil then
            require('colorizer').attach_to_buffer(bufnr, { mode = 'background', css = true })
          end
          return bufnr, winnr
        end,
      },
      on_attach = function(client, bufnr)
        set_lsp_keymaps(client, bufnr)
      end,
    })

    -- GO ----------------------------------------------------------------------

    lspconfig.gopls.setup({
      capabilities = capabilitiesWithoutSnippets,
      on_attach = function(client, bufnr)
        set_lsp_keymaps(client, bufnr)
        format_on_save(bufnr)
        disable_semantic_tokens(client)
      end,
    })

    -- VIM ---------------------------------------------------------------------

    lspconfig.vimls.setup({
      capabilities = capabilities,
      on_attach = function(client, bufnr)
        set_lsp_keymaps(client, bufnr)
        disable_semantic_tokens(client)
      end,
    })

    -- NULL --------------------------------------------------------------------

    local null_ls = require('null-ls')
    local nls_h = require('null-ls.helpers')
    local nls_u = require('null-ls.utils')

    null_ls.setup({
      sources = {
        -- npm i -g @fsouza/prettierd
        null_ls.builtins.formatting.prettierd.with({
          filetypes = vim.list_extend(null_ls.builtins.formatting.prettierd.filetypes, {
            'astro',
          }),
        }),

        -- npm i -g eslint_d
        null_ls.builtins.diagnostics.eslint_d.with({
          diagnostics_format = '#{c}: #{m}',
          root_dir = nls_u.root_pattern('.git'),
          cwd = nls_h.cache.by_bufnr(function(params)
            return nls_u.root_pattern('.git')(params.bufname)
          end),
          filetypes = {
            'javascript',
            'javascriptreact',
            'typescript',
            'typescriptreact',
            'vue',
            'astro',
          },
        }),

        -- Install with Mason
        null_ls.builtins.formatting.goimports,
        null_ls.builtins.formatting.stylua,
      },
      on_attach = function(client, bufnr)
        format_on_save(bufnr)
        disable_semantic_tokens(client)
      end,
      handlers = {
        ['textDocument/publishDiagnostics'] = vim.diagnostic.config({
          underline = false,
          update_in_insert = false,
        }),
      },
    })

    -- DENO --------------------------------------------------------------------

    -- lspconfig.denols.setup({
    --   capabilities = capabilities,
    --   single_file_support = false,
    --   root_dir = lspconfig.util.root_pattern('deno.json', 'deno.jsonc'),

    --   on_attach = function(client, bufnr)
    --     set_lsp_keymaps(client, bufnr)
    --     format_on_save(bufnr)
    --   end,
    -- })
  end,
}
