return {
  'rest-nvim/rest.nvim',
  commit = '91badd46c60df6bd9800c809056af2d80d33da4c',
  lazy = true,
  ft = 'http',
  config = function()
    require('rest-nvim').setup({
      result_split_horizontal = false,
      result_split_in_place = false,
      skip_ssl_verification = false,
      encode_url = true,
      highlight = {
        enabled = true,
        timeout = 150,
      },
      result = {
        show_url = true,
        show_http_info = true,
        show_headers = true,
        formatters = {
          json = 'jq',
          html = function(body)
            return vim.fn.system({ 'tidy', '-i', '-q', '-' }, body)
          end,
        },
      },
      jump_to_request = false,
      env_file = 'env',
      custom_dynamic_variables = {},
      yank_dry_run = true,
    })
  end,
}
