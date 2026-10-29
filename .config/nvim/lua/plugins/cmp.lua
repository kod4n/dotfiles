return {
  {
    'hrsh7th/nvim-cmp',
    event = 'InsertEnter',
    dependencies = {
      {
        'L3MON4D3/LuaSnip',
        build = (function()
          if vim.fn.has 'win32' == 1 or vim.fn.executable 'make' == 0 then
            return
          end
          return 'make install_jsregexp'
        end)(),
        dependencies = {
          -- `friendly-snippets` contains a variety of premade snippets.
          --    See the README about individual language/framework/plugin snippets:
          --    https://github.com/rafamadriz/friendly-snippets
          -- {
          --   'rafamadriz/friendly-snippets',
          --   config = function()
          --     require('luasnip.loaders.from_vscode').lazy_load()
          --   end,
          -- },
        },
      },
      'saadparwaiz1/cmp_luasnip',
      'hrsh7th/cmp-nvim-lsp',
      'hrsh7th/cmp-path',
    },
    config = function()
      local ui = require 'config.ui'
      local cmp = require 'cmp'
      local luasnip = require 'luasnip'
      luasnip.config.setup {}

      -- Consistent borders for Neovim floating windows.
      vim.o.winborder = 'rounded'

      vim.api.nvim_set_hl(0, 'FloatBorder', ui.float_border)

      cmp.setup {
        snippet = {
          expand = function(args)
            luasnip.lsp_expand(args.body)
          end,
        },
        completion = { completeopt = 'menu,menuone,noinsert' },
        window = {
          border = ui.border,
          winhighlight = 'Normal:NormalFloat,FloatBorder:FloatBorder,CursorLine:PmenuSel',
          side_padding = 1,
          scrollbar = true,
          completion = {
            border = ui.border,
            winhighlight = table.concat({
              'Normal:NormalFloat',
              'FloatBorder:FloatBorder',
              'CursorLine:PmenuSel',
              'Search:None',
            }, ','),
            col_offset = -1,
            side_padding = 1,
            scrollbar = true,
          },
          documentation = {
            border = ui.border,
            winhighlight = table.concat({
              'Normal:NormalFloat',
              'FloatBorder:FloatBorder',
              'CursorLine:Visual',
              'Search:None',
            }, ','),
            max_width = 80,
            max_height = 20,
          },
        },
        mapping = cmp.mapping.preset.insert {
          ['<C-n>'] = cmp.mapping.select_next_item(),
          ['<C-p>'] = cmp.mapping.select_prev_item(),

          ['<C-b>'] = cmp.mapping.scroll_docs(-4),
          ['<C-f>'] = cmp.mapping.scroll_docs(4),

          ['<C-y>'] = cmp.mapping.confirm { select = true },

          ['<C-Space>'] = cmp.mapping.complete {},

          ['<C-l>'] = cmp.mapping(function()
            if luasnip.expand_or_locally_jumpable() then
              luasnip.expand_or_jump()
            end
          end, { 'i', 's' }),
          ['<C-h>'] = cmp.mapping(function()
            if luasnip.locally_jumpable(-1) then
              luasnip.jump(-1)
            end
          end, { 'i', 's' }),
        },
        sources = {
          { name = 'nvim_lsp' },
          { name = 'luasnip' },
          { name = 'path' },
        },
      }

      vim.diagnostic.config {
        float = {
          focusable = false,
          style = 'minimal',
          border = 'rounded',
          source = true,
          header = '',
          prefix = '',
        },
      }
    end,
  },
}
