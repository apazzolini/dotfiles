local dap = require('dap')

dap.adapters.node2 = {
  type = 'executable',
  command = 'node',
  args = { os.getenv('HOME') .. '/GitHub/vscode-node-debug2/out/src/nodeDebug.js' },
}

dap.configurations.typescript = {
  {
    name = 'Attach to process',
    type = 'node2',
    request = 'attach',
    processId = require('dap.utils').pick_process,
  },
}
dap.configurations.javascript = dap.configurations.typescript

require('dapui').setup({
  icons = { expanded = '▾', collapsed = '▸' },
  mappings = {
    -- Use a table to apply multiple mappings
    expand = { '<CR>', '<2-LeftMouse>' },
    open = 'o',
    remove = 'd',
    edit = 'e',
    repl = 'r',
    toggle = 't',
  },
  sidebar = {
    -- You can change the order of elements in the sidebar
    elements = {
      -- Provide as ID strings or tables with "id" and "size" keys
      {
        id = 'scopes',
        size = 0.25, -- Can be float or integer > 1
      },
      { id = 'breakpoints', size = 0.25 },
      { id = 'stacks', size = 0.25 },
      { id = 'watches', size = 00.25 },
    },
    size = 40,
    position = 'left', -- Can be "left", "right", "top", "bottom"
  },
  tray = {
    elements = { 'repl' },
    size = 10,
    position = 'bottom', -- Can be "left", "right", "top", "bottom"
  },
  floating = {
    max_height = nil, -- These can be integers or a float between 0 and 1.
    max_width = nil, -- Floats will be treated as percentage of your screen.
    border = 'single', -- Border style. Can be "single", "double" or "rounded"
    mappings = {
      close = { 'q', '<Esc>' },
    },
  },
  windows = { indent = 1 },
})

vim.api.nvim_set_keymap('n', '<leader>dc', "<cmd>silent lua require('dap').continue()<cr>", {})
vim.api.nvim_set_keymap('n', '<leader>dC', "<cmd>lua require('dap').disconnect()<cr>", {})
vim.api.nvim_set_keymap('n', '<leader>dt', "<cmd>lua require('dap').toggle_breakpoint()<cr>", {})
vim.api.nvim_set_keymap('n', '<leader>du', "<cmd>lua require('dapui').open()<cr>", {})
vim.api.nvim_set_keymap('n', '<leader>dU', "<cmd>lua require('dapui').close()<cr>", {})
vim.api.nvim_set_keymap('n', '<leader>dj', "<cmd>lua require('dap').step_over()<cr>", {})
vim.api.nvim_set_keymap('n', '<leader>dl', "<cmd>lua require('dap').step_into()<cr>", {})
vim.api.nvim_set_keymap('n', '<leader>dh', "<cmd>lua require('dap').step_out()<cr>", {})
