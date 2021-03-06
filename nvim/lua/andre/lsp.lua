local log = require 'vim.lsp.log';
local util = require 'vim.lsp.util'

--------------------------------------------------------------------------------

require('lspinstall').setup()
local servers = require'lspinstall'.installed_servers()
for _, server in pairs(servers) do
  require('lspconfig')[server].setup{}
end

--------------------------------------------------------------------------------

vim.fn.sign_define('LspDiagnosticsSignError',
  { text = ">", texthl = "LspDiagnosticsSignError", linehl = '', numhl = '' })
vim.fn.sign_define('LspDiagnosticsSignWarning',
  { text = ">" , texthl = "LspDiagnosticsSignWarning", linehl = '', numhl = '' })
vim.fn.sign_define('LspDiagnosticsSignInformation',
  { text = ">" , texthl = "LspDiagnosticsSignInformation", linehl = '', numhl = '' })
vim.fn.sign_define('LspDiagnosticsSignHint',
  { text = ">" , texthl = "LspDiagnosticsSignHint",  linehl = '', numhl = '' })

function first_match(_, method, result)
  if result == nil or vim.tbl_isempty(result) then
    local _ = log.info() and log.info(method, 'No location found')
    return nil
  end

  if vim.tbl_islist(result) then
    util.jump_to_location(result[1])
  else
    util.jump_to_location(result)
  end

  vim.cmd('normal zz')
end

require'lspconfig'.tsserver.setup{
  on_attach = function(client, bufnr)
    local opts = { noremap = true, silent = true }

    vim.api.nvim_set_keymap('n', 'gd', '<cmd>lua vim.lsp.buf.definition()<cr>', opts)
    vim.api.nvim_set_keymap('n', 'gD', '<cmd>lua vim.lsp.buf.type_definition()<cr>zz', opts)
    vim.api.nvim_set_keymap('n', 'gi', '<cmd>lua vim.lsp.buf.implementation()<cr>zz', opts)
    vim.api.nvim_set_keymap('n', 'gr', '<cmd>lua vim.lsp.buf.references()<cr>', opts)
    vim.api.nvim_set_keymap('n', 'gh', '<cmd>lua vim.lsp.buf.hover()<cr>', opts)
    vim.api.nvim_set_keymap('n', ',H', '<cmd>lua vim.lsp.buf.code_action()<cr>', opts)

    local diagnosticOpts = '{ severity_limit = "Error", popup_opts = { severity_limit = "Error" }}'
    vim.api.nvim_set_keymap('n', ',m', '<cmd>lua vim.lsp.diagnostic.goto_prev(' .. diagnosticOpts .. ')<cr>zz', opts)
    vim.api.nvim_set_keymap('n', ',.', '<cmd>lua vim.lsp.diagnostic.goto_next(' .. diagnosticOpts .. ')<cr>zz', opts)

    vim.api.nvim_set_keymap('n', ',lt', '<cmd>cexpr system("tsc --pretty false") <bar> copen<cr>', opts)
    vim.api.nvim_set_keymap('n', ',la', '<cmd>cexpr system("npm run lint -- --format unix") <bar> copen<cr>', opts)
    vim.api.nvim_set_keymap('n', ',lf', '<cmd>%!eslint_d --stdin --fix-to-stdout --stdin-filename %<cr>', opts)
		vim.api.nvim_set_keymap('n', ',S', '<cmd>silent !touch ~/Work/swt/andre/4/frontend/tailwind.config.js<cr>', opts)

    -- disable tsserver's formatting but assume that prettier via efm will exist,
    -- which we want to trigger on save
    client.resolved_capabilities.document_formatting = false
    vim.cmd [[augroup Format]]
    vim.cmd [[autocmd! * <buffer>]]
    vim.cmd [[autocmd BufWritePre <buffer> lua vim.lsp.buf.formatting_sync(null, 2000)]]
		-- vim.cmd [[autocmd BufWritePost <buffer> <silent> !touch ~/Work/swt/andre/4/frontend/tailwind.config.js]]
    vim.cmd [[augroup END]]
  end,
  flags = {
    debounce_text_changes = 200,
  },
	handlers = {
		["textDocument/publishDiagnostics"] = vim.lsp.with(
			vim.lsp.diagnostic.on_publish_diagnostics, {
				underline = false,
				virtual_text = {
					severity_limit = "Error"
				},
				update_in_insert = false,
				signs = {
					severity_limit = "Error"
				},
			}
		),
    ["textDocument/definition"] = first_match,
    ["textDocument/typeDefinition"] = first_match
	}
}

--------------------------------------------------------------------------------

local prettier = {
  formatCommand = "prettier_d_slim --stdin --stdin-filepath ${INPUT}",
  formatStdin = true,
}

local eslint = {
  lintCommand = "eslint_d -f unix --stdin --stdin-filename ${INPUT}",
  lintStdin = true,
  lintFormats = {"%f:%l:%c: %m"},
  lintIgnoreExitCode = true,
}

require'lspconfig'.efm.setup({
  filetypes = {
    'javascript',
    'typescript',
    'typescriptreact',
    'less',
  },
  init_options = {
    documentFormatting = true,
  },
  settings = {
    languages = {
      javascript = { prettier, eslint },
      typescript = { prettier, eslint },
      javascriptreact = { prettier, eslint },
      typescriptreact = { prettier, eslint },
      less = { prettier },
    }
  },
  handlers = {
    ["textDocument/publishDiagnostics"] = vim.lsp.with(
      vim.lsp.diagnostic.on_publish_diagnostics, {
        underline = false,
        update_in_insert = false,
      }
    ),
  },
})
