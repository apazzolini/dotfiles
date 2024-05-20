vim.filetype.add({
  extension = {
    astro = 'astro',
    mdx = 'markdown',
  },
  filename = {},
  pattern = {
    ['.*/zsh/functions/.*'] = 'zsh',
    ['gitconfig.*'] = 'gitconfig',
    ['${HOME}/.local/share/nvim/lazy/.*/doc/.*/*.txt'] = 'help',
  },
})
