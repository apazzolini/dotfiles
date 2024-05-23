return {
  'mfussenegger/nvim-dap',
  lazy = false, -- :lua require('dap') to load DAP
  dependencies = {
    'rcarriga/nvim-dap-ui',
    'nvim-neotest/nvim-nio',
    'mxsdev/nvim-dap-vscode-js', -- Install instructions: https://github.com/mxsdev/nvim-dap-vscode-js
  },
  config = function()
    local dap = require('dap')
    local ui = require('dapui')

    require('dap-vscode-js').setup({
      debugger_path = os.getenv('HOME') .. '/GitHub/vscode-js-debug/', -- Path to vscode-js-debug installation.
      adapters = { 'pwa-node', 'pwa-chrome', 'pwa-msedge', 'node-terminal', 'pwa-extensionHost' }, -- which adapters to register in nvim-dap
    })

    for _, language in ipairs({ 'typescript', 'javascript' }) do
      dap.configurations[language] = {
        {
          type = 'pwa-node',
          request = 'attach',
          name = 'Attach',
          cwd = '${workspaceFolder}',
          address = '127.0.0.1',
          port = 9231,
        },
      }
    end

    ui.setup({
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

    vim.keymap.set('n', '<leader>dc', dap.continue)
    vim.keymap.set('n', '<leader>dC', dap.disconnect)
    vim.keymap.set('n', '<leader>dt', dap.toggle_breakpoint)
    vim.keymap.set('n', 'rleader>du', ui.open)
    vim.keymap.set('n', '<leader>dU', ui.close)
    vim.keymap.set('n', '<leader>dj', dap.step_over)
    vim.keymap.set('n', '<leader>dl', dap.step_into)
    vim.keymap.set('n', '<leader>dh', dap.step_out)

    vim.keymap.set('n', '<F1>', dap.continue)
    vim.keymap.set('n', '<F2>', dap.step_into)
    vim.keymap.set('n', '<F3>', dap.step_over)
    vim.keymap.set('n', '<F4>', dap.step_out)
    vim.keymap.set('n', '<F5>', dap.step_back)
    vim.keymap.set('n', '<F13>', dap.restart)

    dap.listeners.before.attach.dapui_config = function()
      ui.open()
    end
    dap.listeners.before.launch.dapui_config = function()
      ui.open()
    end
    dap.listeners.before.event_terminated.dapui_config = function()
      ui.close()
    end
    dap.listeners.before.event_exited.dapui_config = function()
      ui.close()
    end
  end,
}
