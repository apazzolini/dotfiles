return {
  cond = vim.g.isNotes == false,
  'mfussenegger/nvim-lint',
  config = function()
    vim.env.ESLINT_D_PPID = vim.fn.getpid()
    require('lint').linters_by_ft = {
      javascript = { 'eslint_d' },
      javascriptreact = { 'eslint_d' },
      typescript = { 'eslint_d' },
      typescriptreact = { 'eslint_d' },
      astro = { 'eslint_d' },
    }

    vim.api.nvim_create_autocmd({ 'InsertLeave', 'TextChanged', 'BufNew' }, {
      callback = function()
        require('lint').try_lint()
      end,
    })

    vim.diagnostic.config({
      underline = false,
      update_in_insert = false,
      virtual_text = {
        severity = {
          min = vim.diagnostic.severity.ERROR,
        },
        format = function(diagnostic)
          if diagnostic.source == 'eslint_d' then
            return string.format('%s [%s]', diagnostic.message, diagnostic.code)
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

    local opts = { noremap = true, silent = true }
    vim.keymap.set('n', '<leader>la', '<cmd>cexpr system("npm run lint -- --format unix") <bar> copen<cr>', opts)
    vim.keymap.set('n', '<leader>lf', '<cmd>%!eslint_d --stdin --fix-to-stdout --stdin-filename %<cr>', opts)
    vim.keymap.set('n', '<leader>i', function()
      vim.lsp.buf.code_action({ apply = true, context = { only = { 'source.addMissingImports.ts' } } })
      vim.cmd('sleep 100m')
      vim.cmd('%!eslint_d --stdin --fix-to-stdout --stdin-filename %')
    end, opts)

    local errorDiagnostics = '{ severity = ' .. vim.diagnostic.severity.ERROR .. ' }'
    vim.keymap.set('n', '<leader>m', '<cmd>lua vim.diagnostic.goto_prev(' .. errorDiagnostics .. ')<cr>zz', opts)
    vim.keymap.set('n', '<leader>.', '<cmd>lua vim.diagnostic.goto_next(' .. errorDiagnostics .. ')<cr>zz', opts)
    vim.keymap.set('n', 'gH', '<cmd>lua vim.diagnostic.open_float()<cr>', opts)
    vim.keymap.set('n', '<leader>le', '<cmd>lua vim.diagnostic.setqflist(' .. errorDiagnostics .. ')<cr>zz', opts)
    vim.keymap.set('n', '<leader>lE', '<cmd>lua vim.diagnostic.setqflist()<cr>zz', opts)
  end,
}
