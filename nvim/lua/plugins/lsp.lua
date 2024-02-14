return {
  cond = vim.g.isNotes == false,
  'hrsh7th/nvim-cmp',
  dependencies = {
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
    'nvimtools/none-ls.nvim',
    'folke/neodev.nvim',
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

      vim.keymap.set('n', '<leader>lq', '<cmd>lua vim.diagnostic.setqflist(' .. errorDiagnostics .. ')<cr>zz', opts)
      vim.keymap.set('n', '<leader>lt', '<cmd>cexpr system("tsc -p frontend -p server --pretty false") <bar> copen<cr>', opts)
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
        format_on_save(bufnr)
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
    local nls_cmd_resolver = require('null-ls.helpers.command_resolver')
    null_ls.setup({
      sources = {
        -- git clone https://github.com/apazzolini/prettier_d_slim.git ~/GitHub/prettier_d_slim
        -- cd ~/GitHub/prettier_d_slim
        -- npm i
        -- ./script/build
        -- npm i -g $(pwd)

        -- When using actual null_ls, there's a builtin
        -- null_ls.builtins.formatting.prettier_d_slim,

        null_ls.builtins.formatting.prettierd.with({
          generator_opts = {
            command = 'prettier_d_slim',
            args = nls_h.range_formatting_args_factory(
              { '--stdin', '--stdin-filepath', '$FILENAME' },
              '--range-start',
              '--range-end',
              { row_offset = -1, col_offset = -1 }
            ),
            to_stdin = true,
            dynamic_command = nls_cmd_resolver.from_node_modules(),
            cwd = nls_h.cache.by_bufnr(function(params)
              return nls_u.cosmiconfig('prettier')(params.bufname)
            end),
          },
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
