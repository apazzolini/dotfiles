return {
  'dmmulroy/tsc.nvim',
  config = function()
    local opts = {}

    if vim.fn.getcwd():match('Work/server') then
      opts.flags = '-b server frontend tokens-server'
    end

    require('tsc').setup(opts)
  end,
}
