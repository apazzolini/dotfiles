if not pcall(require, 'nvim-surround') then
  return
end

require('nvim-surround').setup({
  surrounds = {
    ['c'] = {
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
