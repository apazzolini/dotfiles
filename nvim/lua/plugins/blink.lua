return {
  'saghen/blink.cmp',
  enabled = true,
  cond = vim.g.isNotes == false,
  dependencies = { 'L3MON4D3/LuaSnip', version = 'v2.*' },
  config = function()
    vim.cmd('highlight Pmenu guibg=none')
    vim.cmd('highlight PmenuExtra guibg=none')
    vim.cmd('highlight FloatBorder guibg=none')
    vim.cmd('highlight NormalFloat guibg=none')

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
            auto_show_delay_ms = 500,
            treesitter_highlighting = true,
            window = {
              border = 'rounded',
              -- border = nil,
              scrollbar = false,
              -- winhighlight = 'Normal:BlinkCmpDoc,FloatBorder:BlinkCmpDocBorder,EndOfBuffer:BlinkCmpDoc',
            },
          },
          -- keyword = {
          --   range = 'prefix',
          -- },
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
            max_height = 20,
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

        snippets = {
          preset = 'luasnip',
        },

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

          providers = {
            snippets = {
              should_show_items = function(ctx)
                return ctx.trigger.initial_kind ~= 'trigger_character'
              end,
            },
          },
        },

        -- fuzzy = {
        --   implementation = 'rust',
        --   use_frecency = false,
        --   use_proximity = false,
        --   max_typos = function(_)
        --     return 0
        --   end,
        --   prebuilt_binaries = {
        --     download = true,
        --     ignore_version_mismatch = false,
        --   },
        --   sorts = {
        --     'exact',
        --     -- defaults
        --     'score',
        --     'sort_text',
        --   },
        -- },
      }
    )

    for _, ft_path in ipairs(vim.api.nvim_get_runtime_file('lua/snippets/*.lua', true)) do
      loadfile(ft_path)()
    end
  end,
}

-- return {
--   { 'L3MON4D3/LuaSnip', keys = {} },
--   {
--     'saghen/blink.cmp',
--     enabled = false,
--     dependencies = {
--       'rafamadriz/friendly-snippets',
--     },
--     -- event = "InsertEnter",
--     version = '*',
--     config = function()
--       vim.cmd('highlight Pmenu guibg=none')
--       vim.cmd('highlight PmenuExtra guibg=none')
--       vim.cmd('highlight FloatBorder guibg=none')
--       vim.cmd('highlight NormalFloat guibg=none')
--
--       require('blink.cmp').setup({
--         snippets = { preset = 'luasnip' },
--         signature = { enabled = true },
--         appearance = {
--           use_nvim_cmp_as_default = false,
--           nerd_font_variant = 'normal',
--         },
--         sources = {
--           per_filetype = {
--             codecompanion = { 'codecompanion' },
--           },
--           default = { 'lsp', 'path', 'snippets', 'buffer' },
--           providers = {
--             cmdline = {
--               min_keyword_length = 2,
--             },
--           },
--         },
--         keymap = {
--           ['<C-f>'] = {},
--         },
--         cmdline = {
--           enabled = false,
--           completion = { menu = { auto_show = true } },
--           keymap = {
--             ['<CR>'] = { 'accept_and_enter', 'fallback' },
--           },
--         },
--         completion = {
--           menu = {
--             border = nil,
--             scrolloff = 1,
--             scrollbar = false,
--             draw = {
--               columns = {
--                 { 'kind_icon' },
--                 { 'label', 'label_description', gap = 1 },
--                 { 'kind' },
--                 { 'source_name' },
--               },
--             },
--           },
--           documentation = {
--             window = {
--               border = nil,
--               scrollbar = false,
--               winhighlight = 'Normal:BlinkCmpDoc,FloatBorder:BlinkCmpDocBorder,EndOfBuffer:BlinkCmpDoc',
--             },
--             auto_show = true,
--             auto_show_delay_ms = 500,
--           },
--         },
--       })
--
--       require('luasnip.loaders.from_vscode').lazy_load()
--     end,
--   },
-- }
