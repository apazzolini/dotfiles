if not pcall(require, 'cmp') then
  return
end

local log = require('vim.lsp.log')
local util = require('vim.lsp.util')

--------------------------------------------------------------------------------

vim.fn.sign_define('LspDiagnosticsSignError', { text = '>', texthl = 'LspDiagnosticsSignError', linehl = '', numhl = '' })
vim.fn.sign_define('LspDiagnosticsSignWarning', { text = '>', texthl = 'LspDiagnosticsSignWarning', linehl = '', numhl = '' })
vim.fn.sign_define('LspDiagnosticsSignInformation', { text = '>', texthl = 'LspDiagnosticsSignInformation', linehl = '', numhl = '' })
vim.fn.sign_define('LspDiagnosticsSignHint', { text = '>', texthl = 'LspDiagnosticsSignHint', linehl = '', numhl = '' })

local function set_lsp_keymaps(client, bufnr)
  local opts = { noremap = true, silent = true }

  vim.api.nvim_set_keymap('n', 'gd', '<cmd>lua vim.lsp.buf.definition()<cr>', opts)
  vim.api.nvim_set_keymap('n', 'gD', '<cmd>lua vim.lsp.buf.type_definition()<cr>zz', opts)
  vim.api.nvim_set_keymap('n', 'gI', '<cmd>lua vim.lsp.buf.implementation()<cr>zz', opts)
  vim.api.nvim_set_keymap('n', 'gr', '<cmd>lua vim.lsp.buf.references()<cr>', opts)
  vim.api.nvim_set_keymap('n', 'gh', '<cmd>lua vim.lsp.buf.hover()<cr>', opts)
  -- vim.api.nvim_set_keymap('n', ',H', '<cmd>lua vim.lsp.buf.code_action()<cr>', opts)

  local diagnosticOpts = '{ severity = ' .. vim.diagnostic.severity.ERROR .. ' }'
  vim.api.nvim_set_keymap('n', '<leader>m', '<cmd>lua vim.diagnostic.goto_prev(' .. diagnosticOpts .. ')<cr>zz', opts)
  vim.api.nvim_set_keymap('n', '<leader>.', '<cmd>lua vim.diagnostic.goto_next(' .. diagnosticOpts .. ')<cr>zz', opts)

  vim.api.nvim_set_keymap('n', '<leader>lq', '<cmd>lua vim.diagnostic.setqflist(' .. diagnosticOpts .. ')<cr>zz', opts)
  vim.api.nvim_set_keymap('n', '<leader>lt', '<cmd>cexpr system("tsc --pretty false") <bar> copen<cr>', opts)
  vim.api.nvim_set_keymap('n', '<leader>la', '<cmd>cexpr system("npm run lint -- --format unix") <bar> copen<cr>', opts)
  vim.api.nvim_set_keymap('n', '<leader>lf', '<cmd>%!eslint_d --stdin --fix-to-stdout --stdin-filename %<cr>', opts)

  vim.api.nvim_set_keymap('n', '<leader>F', '<cmd>lua vim.lsp.buf.format({ timeout_ms = 2000 })<cr>', opts)
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

  if vim.tbl_islist(result) then
    util.jump_to_location(result[1], vim.lsp.get_client_by_id(context.client_id).offset_encoding)
  else
    util.jump_to_location(result, vim.lsp.get_client_by_id(context.client_id).offset_encoding)
  end

  vim.cmd('normal zz')
end

--------------------------------------------------------------------------------

require('nvim-lsp-installer').setup({})
local capabilities = require('cmp_nvim_lsp').default_capabilities()
local lspconfig = require('lspconfig')

-- TSSERVER --------------------------------------------------------------------

lspconfig.tsserver.setup({
  capabilities = capabilities,
  root_dir = lspconfig.util.root_pattern('package.json'),

  init_options = {
    preferences = {
      importModuleSpecifierPreference = 'non-relative',
      includePackageJsonAutoImports = 'off',
    },
  },

  on_attach = function(client, bufnr)
    -- use prettier via efm on save instead of tsserver's builtin formatting
    client.server_capabilities.documentFormattingProvider = false
    client.server_capabilities.documentRangeFormattingProvider = false
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

-- JSONLS ----------------------------------------------------------------------

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
  end,
})

-- DENO ------------------------------------------------------------------------

lspconfig.denols.setup({
  capabilities = capabilities,
  single_file_support = false,
  root_dir = lspconfig.util.root_pattern('deno.json', 'deno.jsonc'),

  on_attach = function(client, bufnr)
    vim.cmd([[
      augroup Format
        autocmd! * <buffer>
        autocmd BufWritePre <buffer> lua vim.lsp.buf.format({ timeout_ms = 2000 })
      augroup END
    ]])
    set_lsp_keymaps(client, bufnr)
  end,
})

-- EFM -------------------------------------------------------------------------

local prettier = {
  formatCommand = 'prettier_d_slim --stdin --stdin-filepath ${INPUT}',
  formatStdin = true,
}

local eslint = {
  lintCommand = 'eslint_d -f visualstudio --stdin --stdin-filename ${INPUT}',
  lintStdin = true,
  -- lintFormats = { '%f:%l:%c: %m' },
  lintFormats = {
    '%f(%l,%c): %tarning %m',
    '%f(%l,%c): %rror %m',
  },
  lintIgnoreExitCode = true,
}

local shellcheck = {
  lintCommand = 'shellcheck -f gcc -x',
  lintSource = 'shellcheck',
  lintFormats = { '%f:%l:%c: %trror: %m', '%f:%l:%c: %tarning: %m', '%f:%l:%c: %tote: %m' },
}

lspconfig.efm.setup({
  filetypes = {
    'javascript',
    'typescript',
    'javascriptreact',
    'typescriptreact',
    'less',
    'css',
    'json',
    'sh',
    'markdown',
  },

  single_file_support = false,
  root_dir = function(fname)
    is_deno = lspconfig.util.root_pattern('deno.json', 'deno.jsonc')(fname)
    if is_deno then
      return nil
    end
    return lspconfig.util.root_pattern('.git')(fname)
  end,

  init_options = {
    documentFormatting = true,
  },

  on_attach = function(client, bufnr)
    vim.cmd([[
      augroup Format
        autocmd! * <buffer>
        autocmd BufWritePre <buffer> lua vim.lsp.buf.format({ timeout_ms = 2000 })
      augroup END
    ]])
  end,

  settings = {
    languages = {
      javascript = { prettier, eslint },
      typescript = { prettier, eslint },
      javascriptreact = { prettier, eslint },
      typescriptreact = { prettier, eslint },
      less = { prettier },
      css = { prettier },
      json = { prettier },
      markdown = { prettier },
      sh = { shellcheck },
    },
  },

  handlers = {
    ['textDocument/publishDiagnostics'] = vim.lsp.with(vim.lsp.diagnostic.on_publish_diagnostics, {
      underline = false,
      update_in_insert = false,
    }),
  },
})

-- SUMNEKO ---------------------------------------------------------------------

lspconfig.sumneko_lua.setup({
  settings = {
    Lua = {
      diagnostics = {
        globals = { 'vim', 'use' },
        disable = { 'lowercase-global' },
      },
      workspace = {
        library = {
          ['/Users/andre/GitHub/_forks/hammerspoon/build/stubs'] = true,
          [vim.fn.expand('$VIMRUNTIME/lua')] = true,
          [vim.fn.expand('$VIMRUNTIME/lua/vim/lsp')] = true,
        },
      },
    },
  },
  on_attach = function(client, bufnr)
    set_lsp_keymaps(client, bufnr)
  end,
})

-- TAILWIND --------------------------------------------------------------------

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
      local markdown_lines = util.convert_input_to_markdown_lines(result.contents)
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

-- GO --------------------------------------------------------------------------

-- lspconfig.go.setup({
--   on_attach = function(client, bufnr)
--     vim.cmd([[
--         augroup Format
--           autocmd! * <buffer>
--           autocmd BufWritePre <buffer> lua vim.lsp.buf.format({ timeout_ms = 2000 })
--         augroup END
--       ]])
--   end,
-- })
