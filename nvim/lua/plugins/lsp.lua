return {
  cond = vim.g.isNotes == false,
  'apazzolini/nvim-cmp',
  dependencies = {
    'hrsh7th/cmp-nvim-lsp',
    'hrsh7th/cmp-buffer',
    'hrsh7th/cmp-path',
    'windwp/nvim-autopairs',
    { 'L3MON4D3/LuaSnip', dependencies = {
      'saadparwaiz1/cmp_luasnip',
    } },
    'neovim/nvim-lspconfig',
    'williamboman/mason.nvim',
    'jose-elias-alvarez/null-ls.nvim',
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

      vim.keymap.set('n', '<leader>tb', function()
        vim.lsp.buf.code_action({
          apply = true,
          filter = function(ca)
            return ca.title:match('Add braces to arrow function') ~= nil or ca.title:match('Remove braces from arrow function') ~= nil
          end,
        })
      end)
      -- vim.keymap.set('n', '<leader>ca', '<cmd>lua vim.lsp.buf.code_action({ filter = function})<cr>', opts)

      local diagnosticOpts = '{ severity = ' .. vim.diagnostic.severity.ERROR .. ' }'
      vim.keymap.set('n', '<leader>m', '<cmd>lua vim.diagnostic.goto_prev(' .. diagnosticOpts .. ')<cr>zz', opts)
      vim.keymap.set('n', '<leader>.', '<cmd>lua vim.diagnostic.goto_next(' .. diagnosticOpts .. ')<cr>zz', opts)

      vim.keymap.set('n', '<leader>lq', '<cmd>lua vim.diagnostic.setqflist(' .. diagnosticOpts .. ')<cr>zz', opts)
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

    local function handler_publishDiagnostics(level)
      return vim.lsp.with(vim.lsp.diagnostic.on_publish_diagnostics, {
        underline = false,
        virtual_text = {
          severity_limit = level,
        },
        update_in_insert = false,
        signs = {
          severity_limit = level,
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
      util.jump_to_location(location, vim.lsp.get_client_by_id(context.client_id).offset_encoding, true)

      vim.cmd('normal zz')
    end

    ----------------------------------------------------------------------------

    require('mason').setup({})
    local capabilities = require('cmp_nvim_lsp').default_capabilities()
    local lspconfig = require('lspconfig')

    -- TSSERVER ----------------------------------------------------------------

    lspconfig.tsserver.setup({
      capabilities = capabilities,
      root_dir = function(fname)
        return lspconfig.util.root_pattern('pnpm-workspace.yaml')(fname)
          or lspconfig.util.root_pattern('tsconfig.json')(fname)
          or lspconfig.util.root_pattern('package.json', 'jsconfig.json', '.git')(fname)
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
        client.server_capabilities.documentFormattingProvider = false
        client.server_capabilities.documentRangeFormattingProvider = false
        disable_semantic_tokens(client)
        set_lsp_keymaps(client, bufnr)
      end,
      flags = {
        debounce_text_changes = 200,
      },
      handlers = {
        ['textDocument/publishDiagnostics'] = handler_publishDiagnostics('Error'),
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
        client.server_capabilities.documentFormattingProvider = false
        client.server_capabilities.documentRangeFormattingProvider = false
        disable_semantic_tokens(client)
      end,
    })

    -- ASTRO -------------------------------------------------------------------

    lspconfig.astro.setup({
      capabilities = capabilities,
      on_attach = function(client, bufnr)
        set_lsp_keymaps(client, bufnr)
        format_on_save(bufnr)
        client.server_capabilities.snippetSupport = false
        disable_semantic_tokens(client)
      end,
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

    -- LUA_LS ------------------------------------------------------------------

    lspconfig.lua_ls.setup({
      settings = {
        Lua = {
          -- runtime = {
          --   path = { 'lua/?.lua', 'init.lua' },
          --   pathStrict = true,
          -- },
          -- diagnostics = {
          --   globals = { 'vim' },
          --   -- disable = { 'lowercase-global' },
          -- },
          workspace = {
            -- library = vim.api.nvim_get_runtime_file('', true),
            checkThirdParty = false,
          },
          telemetry = {
            enable = false,
          },
        },
      },
      on_attach = function(client, bufnr)
        disable_semantic_tokens(client)
        set_lsp_keymaps(client, bufnr)
      end,
    })

    -- TAILWIND ----------------------------------------------------------------

    lspconfig.tailwindcss.setup({
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
          config = config or {}
          config.focus_id = ctx.method
          if not (result and result.contents) then
            -- return { 'No information available' }
            return
          end
          local markdown_lines = util.convert_input_to_markdown_lines(result.contents, {})
          markdown_lines = util.trim_empty_lines(markdown_lines)
          if vim.tbl_isempty(markdown_lines) then
            -- return { 'No information available' }
            return
          end

          -- return util.open_floating_preview(markdown_lines, 'markdown', config)
          local bufnr, winnr = util.open_floating_preview(markdown_lines, 'markdown', config)
          require('colorizer').attach_to_buffer(bufnr)
          -- vim.api.nvim_buf_set_option(bufnr, 'filetype', '...')
          return bufnr, winnr
        end,
      },
    })

    -- GO ----------------------------------------------------------------------

    lspconfig.gopls.setup({
      capabilities = capabilities,
      on_attach = function(client, bufnr)
        set_lsp_keymaps(client, bufnr)
        format_on_save(bufnr)
        client.server_capabilities.snippetSupport = false
        disable_semantic_tokens(client)
      end,
    })

    -- NULL --------------------------------------------------------------------

    local null_ls = require('null-ls')
    local nls_h = require('null-ls.helpers')
    local nls_u = require('null-ls.utils')
    null_ls.setup({
      sources = {
        null_ls.builtins.formatting.prettier_d_slim,
        null_ls.builtins.formatting.goimports,
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
  end,
}
