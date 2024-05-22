local log = require('vim.lsp.log')
local util = require('vim.lsp.util')

return {
  cond = vim.g.isNotes == false,
  'neovim/nvim-lspconfig',
  dependencies = {
    'b0o/schemastore.nvim',
    'windwp/nvim-autopairs',
    'stevearc/conform.nvim',
    {
      'folke/neodev.nvim',
      opts = {
        library = {
          plugins = false,
        },
      },
    },
    'williamboman/mason.nvim',
    {
      'j-hui/fidget.nvim',
      opts = {
        progress = {
          suppress_on_insert = true,
          ignore_done_already = true,
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
    local lspconfig = require('lspconfig')
    require('mason').setup({})

    local servers = {
      astro = true,
      gopls = true,
      vimls = true,
      zls = true,
      eslint = true,

      tsserver = {
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
        flags = {
          debounce_text_changes = 200,
        },
      },

      jsonls = {
        settings = {
          json = {
            schemas = require('schemastore').json.schemas(),
            validate = { enable = true },
          },
        },
      },

      rust_analyzer = {
        cmd = { 'rustup', 'run', 'stable', 'rust-analyzer' },
      },

      lua_ls = {
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
      },

      tailwindcss = {
        -- See README in https://github.com/apazzolini/tailwindcss-intellisense.git
        root_dir = function(fname)
          return lspconfig.util.root_pattern('tailwind.config.js', 'tailwind.config.cjs', 'tailwind.config.mjs', 'tailwind.config.ts')(
            fname
          )
        end,
        single_file_support = false,
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
      },
    }

    ----------------------------------------------------------------------------

    vim.fn.sign_define('LspDiagnosticsSignError', { text = '>' })
    vim.fn.sign_define('LspDiagnosticsSignWarning', { text = '>' })
    vim.fn.sign_define('LspDiagnosticsSignInformation', { text = '>' })
    vim.fn.sign_define('LspDiagnosticsSignHint', { text = '>' })

    ----------------------------------------------------------------------------

    local orig_util_open_floating_preview = vim.lsp.util.open_floating_preview
    function vim.lsp.util.open_floating_preview(contents, syntax, opts, ...)
      opts = opts or {}
      opts.border = opts.border or 'rounded'
      return orig_util_open_floating_preview(contents, syntax, opts, ...)
    end

    ----------------------------------------------------------------------------

    vim.diagnostic.config({
      underline = false,
      update_in_insert = false,
      virtual_text = {
        severity = {
          min = vim.diagnostic.severity.ERROR,
        },
        format = function(diagnostic)
          if diagnostic.source == 'eslint' then
            return string.format(
              '%s [%s]',
              diagnostic.message,
              -- shows the name of the rule
              diagnostic.user_data.lsp.code
            )
          end
          return string.format('%s [%s]', diagnostic.message, diagnostic.source)
        end,
      },
      signs = {
        severity = {
          min = vim.diagnostic.severity.WARN,
        },
      },
    })

    ----------------------------------------------------------------------------

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

    local capabilities = require('cmp_nvim_lsp').default_capabilities({ snippetSupport = false })

    for name, config in pairs(servers) do
      if config == true then
        config = {}
      end

      config = vim.tbl_deep_extend('force', {}, {
        capabilities = capabilities,
        handlers = {
          ['textDocument/definition'] = first_match,
          ['textDocument/typeDefinition'] = first_match,
        },
      }, config)

      lspconfig[name].setup(config)
    end

    ----------------------------------------------------------------------------

    vim.api.nvim_create_autocmd('LspAttach', {
      callback = function(args)
        local client = assert(vim.lsp.get_client_by_id(args.data.client_id), 'must have valid client')
        local opts = { noremap = true, silent = true, buffer = 0 }

        vim.keymap.set('n', 'gd', '<cmd>lua vim.lsp.buf.definition()<cr>', opts)
        vim.keymap.set('n', 'gD', '<cmd>lua vim.lsp.buf.type_definition()<cr>zz', opts)
        vim.keymap.set('n', 'gI', '<cmd>lua vim.lsp.buf.implementation()<cr>zz', opts)
        vim.keymap.set('n', 'gr', '<cmd>lua vim.lsp.buf.references()<cr>', opts)
        vim.keymap.set('n', 'gh', '<cmd>lua vim.lsp.buf.hover()<cr>', opts)
        vim.keymap.set('n', '<leader>ca', '<cmd>lua vim.lsp.buf.code_action()<cr>', opts)

        vim.keymap.set('n', '<cr>', function()
          vim.cmd('noh')
          for _, win in ipairs(vim.api.nvim_list_wins()) do
            local config = vim.api.nvim_win_get_config(win)
            if config.relative ~= '' then
              vim.api.nvim_win_close(win, false)
            end
          end
        end, opts)

        vim.keymap.set('n', '<leader>ci', function()
          vim.lsp.buf.code_action({
            apply = true,
            filter = function(ca)
              return ca.title:match('^Add import from') or ca.title:match('^Update import from')
            end,
          })
        end, opts)

        local errorDiagnostics = '{ severity = ' .. vim.diagnostic.severity.ERROR .. ' }'
        vim.keymap.set('n', '<leader>m', '<cmd>lua vim.diagnostic.goto_prev(' .. errorDiagnostics .. ')<cr>zz', opts)
        vim.keymap.set('n', '<leader>.', '<cmd>lua vim.diagnostic.goto_next(' .. errorDiagnostics .. ')<cr>zz', opts)
        vim.keymap.set('n', 'gH', '<cmd>lua vim.diagnostic.open_float()<cr>', opts)
        vim.keymap.set('n', '<leader>le', '<cmd>lua vim.diagnostic.setqflist(' .. errorDiagnostics .. ')<cr>zz', opts)
        vim.keymap.set('n', '<leader>lE', '<cmd>lua vim.diagnostic.setqflist()<cr>zz', opts)
        vim.keymap.set('n', '<leader>la', '<cmd>cexpr system("npm run lint -- --format unix") <bar> copen<cr>', opts)
        vim.keymap.set('n', '<leader>lf', '<cmd>EslintFixAll<cr>', opts)

        vim.keymap.set('n', '<leader>F', function()
          require('conform').format()
        end, opts)

        client.server_capabilities.semanticTokensProvider = nil
      end,
    })

    ----------------------------------------------------------------------------

    -- npm i -g @fsouza/prettierd, others with Mason
    require('conform').setup({
      formatters_by_ft = {
        lua = { 'stylua' },
        javascript = { 'prettierd' },
        javascriptreact = { 'prettierd' },
        typescript = { 'prettierd' },
        typescriptreact = { 'prettierd' },
        zig = { 'zigfmt' },
      },
      format_on_save = {
        timeout_ms = 2000,
        lsp_fallback = false,
      },
      notify_on_error = false,
    })

    ----------------------------------------------------------------------------

    require('nvim-autopairs').setup()
  end,
}
