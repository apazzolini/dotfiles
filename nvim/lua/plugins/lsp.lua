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
      pylsp = {},
      gopls = {},
      vimls = {},
      zls = {},
      terraformls = {},

      vtsls = {
        root_dir = function(fname)
          return lspconfig.util.root_pattern('pnpm-workspace.yaml')(fname)
            or lspconfig.util.root_pattern('.git')(fname)
            or lspconfig.util.root_pattern('package.json', 'jsconfig.json', 'tsconfig.json')(fname)
        end,
        single_file_support = false,
        settings = {
          typescript = {
            tsserver = {
              maxTsServerMemory = 10240,
              watchOptions = {
                watchDirectory = 'useFsEvents',
                fallbackPolling = 'dynamicPriorityPolling',
                watchFile = 'useFsEventsOnParentDirectory',
                synchronousWatchDirectory = true,
              },
            },
            preferences = {
              importModuleSpecifierPreference = 'shortest',
              includePackageJsonAutoImports = 'off',
            },
          },
          vtsls = {
            autoUseWorkspaceTsdk = true,
            typescript = {
              globalTsdk = false,
            },
            experimental = {
              completion = {
                enableServerSideFuzzyMatch = true,
              },
            },
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
      lspconfig[name].setup(config)
    end

    ----------------------------------------------------------------------------

    local function first_match(list)
      vim.lsp.util.show_document(list.items[1].user_data, 'utf-8', false)
      vim.cmd('normal zz')
    end

    vim.api.nvim_create_autocmd('LspAttach', {
      callback = function(args)
        local client = assert(vim.lsp.get_client_by_id(args.data.client_id), 'must have valid client')
        local opts = { noremap = true, silent = true, buffer = 0 }

        vim.keymap.set('n', 'gd', function()
          vim.lsp.buf.definition({ on_list = first_match })
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
