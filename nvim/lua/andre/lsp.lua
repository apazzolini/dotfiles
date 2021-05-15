vim.fn.sign_define('LspDiagnosticsSignError',
  { text = ">>", texthl = "LspDiagnosticsSignError", linehl = '', numhl = '' })

vim.fn.sign_define('LspDiagnosticsSignWarning',
  { text = ">" , texthl = "LspDiagnosticsSignWarning", linehl = '', numhl = '' })

vim.fn.sign_define('LspDiagnosticsSignInformation',
  { text = ">" , texthl = "LspDiagnosticsSignInformation", linehl = '', numhl = '' })

vim.fn.sign_define('LspDiagnosticsSignHint',
  { text = ">" , texthl = "LspDiagnosticsSignHint",  linehl = '', numhl = '' })

local on_attach = function(client, bufnr)
  local opts = { noremap = true, silent = true }
  vim.api.nvim_set_keymap('n', 'gd', '<cmd>lua vim.lsp.buf.definition()<cr>', opts)
  vim.api.nvim_set_keymap('n', 'gr', '<cmd>lua vim.lsp.buf.references()<cr>', opts)
  vim.api.nvim_set_keymap('n', 'gh', '<cmd>lua vim.lsp.buf.hover()<cr>', opts)
  vim.api.nvim_set_keymap('n', ',m', '<cmd>lua vim.lsp.diagnostic.goto_prev()<cr>', opts)
  vim.api.nvim_set_keymap('n', ',.', '<cmd>lua vim.lsp.diagnostic.goto_next()<cr>', opts)

  client.resolved_capabilities.document_formatting = false
end

-- ["textDocument/publishDiagnostics"] = vim.lsp.with(
  -- vim.lsp.diagnostic.on_publish_diagnostics, {
    -- underline = false,
    -- virtual_text = false,
    -- update_in_insert = false,
    -- signs = false,
  -- }
-- )

require'lspconfig'.tsserver.setup{
  on_attach = on_attach,
  handlers = {
    ["textDocument/publishDiagnostics"] = function() end,
  }
}

vim.lsp.handlers["textDocument/publishDiagnostics"] = vim.lsp.with(
  vim.lsp.diagnostic.on_publish_diagnostics, {
    underline = false,
    update_in_insert = false,
  }
)

require'lspconfig'.efm.setup {
  filetypes = {
    'javascriptreact',
  },
  init_options = {
    documentFormatting = true,
  },
  settings = {
    languages = {
      javascriptreact = {
        {
          lintCommand = "eslint_d -f unix --stdin --stdin-filename ${INPUT}",
          lintStdin = true,
          lintFormats = {"%f:%l:%c: %m"},
          lintIgnoreExitCode = true,
          formatCommand = "prettier_d_slim --stdin --stdin-filepath ${INPUT}",
          formatStdin = true
        }
      },
    }
  },
}

--------------------------------------------------------------------------------------------

if pcall(require, 'compe') then
  require'compe'.setup {
    enabled = true;
    autocomplete = true;
    debug = false;
    min_length = 2;
    preselect = 'enable';
    throttle_time = 80;
    source_timeout = 200;
    incomplete_delay = 400;
    max_abbr_width = 100;
    max_kind_width = 100;
    max_menu_width = 100;
    documentation = true;

    source = {
      path = true;
      buffer = true;
      calc = false;
      nvim_lsp = true;
      nvim_lua = true;
      vsnip = false;
    };
  }
end

local t = function(str)
  return vim.api.nvim_replace_termcodes(str, true, true, true)
end

local check_back_space = function()
  local col = vim.fn.col('.') - 1
  if col == 0 or vim.fn.getline('.'):sub(col, col):match('%s') then
    return true
  else
    return false
  end
end

_G.tab_complete = function()
  if vim.fn.call('neosnippet#expandable_or_jumpable', {}) == 1 then
    return t '<Plug>(neosnippet_expand_or_jump)'
  elseif vim.fn.pumvisible() == 1 then
    return t '<C-n>'
  elseif check_back_space() then
    return t '<Tab>'
  else
    return vim.fn['compe#complete']()
  end
end

vim.api.nvim_set_keymap("i", "<Tab>", "v:lua.tab_complete()", {expr = true})
vim.api.nvim_set_keymap("i", "<S-Tab>", t 'pumvisible() ? "<C-p>" : "<S-TAB>"', {expr = true})
vim.api.nvim_set_keymap("i", "<c-j>", t 'pumvisible() ? "<C-n>" : "<c-j>"', {expr = true})
vim.api.nvim_set_keymap("i", "<c-k>", t 'pumvisible() ? "<C-p>" : "<c-k>"', {expr = true})
vim.api.nvim_set_keymap("i", "<c-space>", 'compe#complete()', {expr = true})
vim.api.nvim_set_keymap("i", "<cr>", t 'compe#confirm("<Plug>(PearTreeExpand)")', {expr = true})
