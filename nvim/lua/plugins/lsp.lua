local log = require('vim.lsp.log')
local util = require('vim.lsp.util')

--[[
MasonInstall astro-language-server eslint_d gopls json-lsp lua-language-server prettierd python-lsp-server stylua vim-language-server vtsls tailwindcss-language-server terraform-ls
]]

return {
  cond = vim.g.isNotes == false,
  'neovim/nvim-lspconfig',
  dependencies = {
    'b0o/schemastore.nvim',
    'yioneko/nvim-vtsls',
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
          ignore = {
            'null-ls',
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
      astro = {},
      pyright = {},
      gopls = {},
      vimls = {},
      zls = {},
      terraformls = {},
      tsgo = {},

      -- vtsls = {
      --   -- root_dir = function(fname)
      --   --   return lspconfig.util.root_pattern('pnpm-workspace.yaml')(fname)
      --   --     or lspconfig.util.root_pattern('.git')(fname)
      --   --     or lspconfig.util.root_pattern('package.json', 'jsconfig.json', 'tsconfig.json')(fname)
      --   -- end,
      --   single_file_support = false,
      --   settings = {
      --     typescript = {
      --       tsserver = {
      --         maxTsServerMemory = 10240,
      --         watchOptions = {
      --           watchDirectory = 'useFsEvents',
      --           fallbackPolling = 'dynamicPriorityPolling',
      --           watchFile = 'useFsEventsOnParentDirectory',
      --           synchronousWatchDirectory = true,
      --         },
      --       },
      --       preferences = {
      --         -- importModuleSpecifierPreference = 'shortest',
      --         includePackageJsonAutoImports = 'off',
      --       },
      --     },
      --     vtsls = {
      --       autoUseWorkspaceTsdk = true,
      --       typescript = {
      --         globalTsdk = false,
      --       },
      --       experimental = {
      --         completion = {
      --           enableServerSideFuzzyMatch = true,
      --         },
      --       },
      --     },
      --   },
      --   flags = {
      --     debounce_text_changes = 200,
      --   },
      -- },

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
              -- library = { vim.env.HOME .. '/.dotfiles/systems/osx/hammerspoon/repo/build/stubs' },
              checkThirdParty = false,
            },
            telemetry = {
              enable = false,
            },
          },
        },
      },

      tailwindcss = {
        single_file_support = false,
        settings = {
          tailwindCSS = {
            experimental = {
              classRegex = {
                'tw`([^`]*)',
                { 'classnames\\(([^)]*)\\)', "'([^']*)'" },
                { 'cva\\(([^)]*)\\)', '["\'`]([^"\'`]*).*?["\'`]' },
                { 'cx\\(([^)]*)\\)', "(?:'|\"|`)([^']*)(?:'|\"|`)" },
                { 'cn\\(([^)]*)\\)', "(?:'|\"|`)([^']*)(?:'|\"|`)" },
              },
            },
          },
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

    for name, config in pairs(servers) do
      vim.lsp.config(name, config)
      vim.lsp.enable(name)
    end

    ----------------------------------------------------------------------------

    local function first_match(list)
      vim.lsp.util.show_document(list.items[1].user_data, 'utf-8', false)
      vim.cmd('normal zt')
    end

    local function refresh_tsgo_diagnostics(bufnr)
      local clients = vim.lsp.get_clients({ bufnr = bufnr, name = 'tsgo' })
      for _, client in pairs(clients) do
        client:request('textDocument/diagnostic', { textDocument = vim.lsp.util.make_text_document_params(bufnr) })
      end
    end

    vim.api.nvim_create_autocmd({ 'BufEnter' }, {
      callback = function()
        refresh_tsgo_diagnostics(vim.api.nvim_get_current_buf())
      end,
    })

    vim.api.nvim_create_autocmd({ 'InsertLeave', 'TextChanged', 'TabEnter' }, {
      callback = function()
        vim.defer_fn(function()
          local deduped_visible_buffers = {}
          for _, win in pairs(vim.api.nvim_tabpage_list_wins(0)) do
            local bufnr = vim.api.nvim_win_get_buf(win)
            deduped_visible_buffers[bufnr] = true
          end
          for bufnr, _ in pairs(deduped_visible_buffers) do
            refresh_tsgo_diagnostics(bufnr)
          end
        end, 100)
      end,
    })

    vim.api.nvim_create_autocmd('LspAttach', {
      callback = function(args)
        local client = assert(vim.lsp.get_client_by_id(args.data.client_id), 'must have valid client')
        local opts = { noremap = true, silent = true, buffer = 0 }

        vim.keymap.set('n', '<leader>gd', function()
          vim.lsp.buf.definition()
        end, opts)

        vim.keymap.set('n', 'gs', function()
          client:request('textDocument/diagnostic', { textDocument = vim.lsp.util.make_text_document_params(0) })
          -- local bufnr = vim.api.nvim_get_current_buf()
          -- for _, client in pairs(vim.lsp.get_active_clients({ bufnr = bufnr })) do
          --   client.request('textDocument/diagnostic', {
          --     textDocument = vim.lsp.util.make_text_document_params(),
          --   })
          -- end
        end)

        -- vim.keymap.set('n', 'gs', function()
        --   local params = vim.lsp.util.make_position_params(0, 'utf-8')
        --   -- params.context = { source_definition = true }
        --
        --   client:request('textDocument/definition', params)
        --
        --   -- vim.lsp.buf.execute_command({
        --   --   command = 'typescript.goToSourceDefinition',
        --   --   arguments = { params.textDocument.uri, params.position },
        --   -- })
        --   -- require('vtsls').commands.goto_source_definition()
        -- end, opts)

        vim.keymap.set('n', 'gd', function()
          vim.lsp.buf.definition({ on_list = first_match })
        end, opts)

        vim.keymap.set('n', '<leader>gD', function()
          vim.lsp.buf.type_definition()
        end, opts)

        vim.keymap.set('n', 'gD', function()
          vim.lsp.buf.type_definition({ on_list = first_match })
        end, opts)

        vim.keymap.set('n', 'gr', vim.lsp.buf.references, opts)
        vim.keymap.set('n', 'gh', vim.lsp.buf.hover, opts)
        vim.keymap.set('n', '<leader>ca', vim.lsp.buf.code_action, opts)
        vim.keymap.set('n', '<leader>cr', vim.lsp.buf.rename, opts)

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

        vim.keymap.set('i', '<c-h>', vim.lsp.buf.signature_help, opts)

        client.server_capabilities.semanticTokensProvider = nil
      end,
    })
  end,
}
