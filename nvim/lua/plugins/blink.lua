return {
  'saghen/blink.cmp',
  enabled = false,
  cond = vim.g.isNotes == false,
  dependencies = { 'L3MON4D3/LuaSnip', version = 'v2.*' },

  -- use a release tag to download pre-built binaries
  version = '1.*',

  config = function()
    require('blink.cmp').setup(
      ---@module 'blink.cmp'
      ---@type blink.cmp.Config
      {
        keymap = {
          preset = 'enter',

          ['<Tab>'] = {
            function(cmp)
              if cmp.snippet_active() then
                return cmp.accept()
              else
                return cmp.select_next()
              end
            end,
            'snippet_forward',
            'fallback',
          },

          ['<S-Tab>'] = { 'snippet_backward', 'select_prev', 'fallback' },
        },
        cmdline = {
          enabled = false,
        },
        completion = {
          documentation = {
            auto_show = true,
            treesitter_highlighting = true,
            window = { border = 'rounded' },
          },
          keyword = {
            range = 'prefix',
          },
          list = {
            selection = {
              preselect = true,
              auto_insert = false,
            },
          },
          accept = {
            dot_repeat = false,
            create_undo_point = true,
            auto_brackets = {
              enabled = true,
            },
          },
          menu = {
            draw = {
              columns = { { 'label', 'label_detail', gap = 1 }, { 'kind' } },
              components = {
                label = {
                  width = { max = 30, fill = true },
                  text = function(ctx)
                    return ctx.label
                  end,
                },
                label_detail = {
                  width = { fill = true, max = 15 },
                  text = function(ctx)
                    return ctx.label_detail
                  end,
                },
                source_name = {},
              },
            },
          },
        },

        appearance = {
          nerd_font_variant = 'mono',
          use_nvim_cmp_as_default = true,
        },

        snippets = { preset = 'luasnip' },

        sources = {
          default = { 'lsp', 'path', 'snippets', 'buffer' },
          transform_items = function(_, items)
            return vim.tbl_filter(function(item)
              local labelDetails = item.labelDetails
              --
              if labelDetails ~= nil and labelDetails.description ~= nil then
                local description = labelDetails.description
                if description:find('^date%-fns/') ~= nil then
                  return false
                end
                if description:find('^@aws') ~= nil then
                  return false
                end
              end

              -- vim.print(item)
              --
              -- if entry:get_filter_text():find('^SVG') ~= nil then
              --   return false
              -- end
              --
              -- vim.print('true')
              return true
            end, items)
          end,
        },

        fuzzy = {
          implementation = 'rust',
          use_frecency = false,
          use_proximity = false,
          max_typos = function(_)
            return 0
          end,
          prebuilt_binaries = {
            download = true,
            ignore_version_mismatch = false,
          },
          sorts = {
            'exact',
            -- defaults
            'score',
            'sort_text',
          },
        },
      }
    )

    for _, ft_path in ipairs(vim.api.nvim_get_runtime_file('lua/snippets/*.lua', true)) do
      loadfile(ft_path)()
    end
  end,
}
