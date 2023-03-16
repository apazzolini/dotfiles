return {
  'kylechui/nvim-surround',
  config = function()
    require('nvim-surround').setup({
      surrounds = {
        ['c'] = {
          add = function()
            return {
              { '{cn("' },
              { '")}' },
            }
          end,
        },
        ['e'] = {
          add = function()
            return {
              { 'try {' },
              { '} catch (e) {}' },
            }
          end,
        },
        ['i'] = {
          add = function()
            return {
              { 'if () {' },
              { '}' },
            }
          end,
        },
      },
    })
  end,
}
