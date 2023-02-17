return {
  'nvim-lua/plenary.nvim',

  'sickill/vim-pasta',
  'tpope/vim-repeat',
  'tpope/vim-unimpaired',
  'tpope/vim-abolish',
  'godlygeek/tabular',

  'nikvdp/ejs-syntax',
  -- 'maxmellon/vim-jsx-pretty',
  -- 'pangloss/vim-javascript',
  'b0o/schemastore.nvim',

  { 'vladdoster/remember.nvim', config = true, opts = {} },

  {
    'romainl/vim-qf',
    config = function()
      vim.g.qf_mapping_ack_style = 1
      vim.keymap.set('n', '[q', ':call qf#wrap#WrapCommand("up", "c")<CR>', { silent = true })
      vim.keymap.set('n', ']q', ':call qf#wrap#WrapCommand("down", "c")<CR>', { silent = true })
      vim.keymap.set('n', '[Q', ':colder<cr>')
      vim.keymap.set('n', ']Q', ':cnewer<cr>')
    end,
  },

  {
    'wellle/targets.vim',
    config = function()
      vim.g.targets_argOpening = '[({[]'
      vim.g.targets_argClosing = '[]})]'
    end,
  },
}
