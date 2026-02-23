return {
  'iamcco/markdown-preview.nvim',
  cmd = { 'MarkdownPreviewToggle', 'MarkdownPreview', 'MarkdownPreviewStop' },
  build = 'cd app && yarn install',
  init = function()
    -- " use a custom highlight style. Must be an absolute path
    -- " like '/Users/username/highlight.css' or expand('~/highlight.css')
    vim.g.mkdp_highlight_css = '/home/andre/.dotfiles/nvim/lua/plugins/markdown.css'
    vim.g.mkdp_filetypes = { 'markdown' }
  end,
  ft = { 'markdown' },
}
