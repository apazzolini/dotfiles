return {
  'mfussenegger/nvim-dap',
  lazy = true, -- :lua require('dap') to load DAP
  dependencies = {
    'rcarriga/nvim-dap-ui',
    'mxsdev/nvim-dap-vscode-js', -- Install instructions: https://github.com/mxsdev/nvim-dap-vscode-js
  },
  config = function()
    require('dap-vscode-js').setup({
      debugger_path = os.getenv('HOME') .. '/GitHub/vscode-js-debug/', -- Path to vscode-js-debug installation.
      adapters = { 'pwa-node', 'pwa-chrome', 'pwa-msedge', 'node-terminal', 'pwa-extensionHost' }, -- which adapters to register in nvim-dap
    })

    for _, language in ipairs({ 'typescript', 'javascript' }) do
      require('dap').configurations[language] = {
        {
          type = 'pwa-node',
          request = 'attach',
          name = 'Attach',
          cwd = '${workspaceFolder}',
        },
      }
    end

    require('dapui').setup({
      icons = { expanded = '▾', collapsed = '▸' },
      mappings = {
        expand = { '<CR>', '<2-LeftMouse>' },
        open = 'o',
        remove = 'd',
        edit = 'e',
        repl = 'r',
        toggle = 't',
      },
      layouts = {
        {
          elements = {
            'scopes',
            'breakpoints',
            'stacks',
            'watches',
          },
          size = 40,
          position = 'left',
        },
        {
          elements = {
            'repl',
            'console',
          },
          size = 10,
          position = 'bottom',
        },
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

    vim.keymap.set('n', '<leader>dc', "<cmd>silent lua require('dap').continue()<cr>", {})
    vim.keymap.set('n', '<leader>dC', "<cmd>lua require('dap').disconnect()<cr>", {})
    vim.keymap.set('n', '<leader>dt', "<cmd>lua require('dap').toggle_breakpoint()<cr>", {})
    vim.keymap.set('n', '<leader>du', "<cmd>lua require('dapui').open()<cr>", {})
    vim.keymap.set('n', '<leader>dU', "<cmd>lua require('dapui').close()<cr>", {})
    vim.keymap.set('n', '<leader>dj', "<cmd>lua require('dap').step_over()<cr>", {})
    vim.keymap.set('n', '<leader>dl', "<cmd>lua require('dap').step_into()<cr>", {})
    vim.keymap.set('n', '<leader>dh', "<cmd>lua require('dap').step_out()<cr>", {})
  end,
}
