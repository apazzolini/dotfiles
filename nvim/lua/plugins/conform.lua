local prettier_pid = -1
local store_prettier_pid = function()
  if prettier_pid == -1 then
    local obj = vim.system({ 'pgrep', '-n', 'prettierd' }, { text = true }, function(out)
      prettier_pid = out.stdout
    end)
  end
end

return {
  cond = vim.g.isNotes == false,
  'stevearc/conform.nvim',
  config = function()
    local formatters_by_ft = {
      lua = { 'stylua' },
      astro = { 'oxfmt', 'prettierd' },
      css = { 'oxfmt', 'prettierd' },
      go = { 'gofmt' },
      html = { 'oxfmt', 'prettierd' },
      json = { 'oxfmt', 'prettierd' },
      jsonc = { 'oxfmt', 'prettierd' },
      javascript = { 'oxfmt', 'prettierd' },
      javascriptreact = { 'oxfmt', 'prettierd' },
      markdown = { 'oxfmt', 'prettierd' },
      terraform = { 'terraform-fmt', lsp_format = 'prefer' },
      typescript = { 'oxfmt', 'prettierd' },
      typescriptreact = { 'oxfmt', 'prettierd' },
      zig = { 'zigfmt' },
    }

    require('conform').setup({
      formatters_by_ft = formatters_by_ft,
      formatters = {
        oxfmt = {
          command = 'oxfmt',
          args = { '$FILENAME' },
          stdin = false,
          -- When stdin=false, use this template to generate the temporary file that gets formatted
          tmpfile_format = '.conform.$RANDOM.$FILENAME',
        },
      },
      format_on_save = function(buf)
        local ft = vim.bo[buf].filetype

        local cb = nil
        if formatters_by_ft[ft] ~= nil and formatters_by_ft[ft][1] == 'prettierd' then
          cb = store_prettier_pid
        end

        return {
          timeout_ms = 2000,
          lsp_fallback = false,
        }, cb
      end,
      notify_on_error = false,
    })

    local opts = { noremap = true, silent = true }
    vim.keymap.set('n', '<leader>F', function(args)
      local ft = vim.bo.filetype

      local cb = nil
      if formatters_by_ft[ft] ~= nil and formatters_by_ft[ft][1] == 'prettierd' then
        cb = store_prettier_pid
      end

      require('conform').format(nil, cb)
    end)

    vim.api.nvim_create_autocmd('VimLeavePre', {
      callback = function()
        if prettier_pid ~= -1 then
          vim.fn.jobstart('kill ' .. prettier_pid, { detach = true })
        end
      end,
    })
  end,
}
