return {
  {
    'nvim-neotest/neotest',
    dependencies = {
      'nvim-neotest/nvim-nio',
      'nvim-lua/plenary.nvim',
      'antoinemadec/FixCursorHold.nvim',
      'nvim-treesitter/nvim-treesitter',
      'nvim-neotest/neotest-plenary',
      'nvim-neotest/neotest-python',
      {
        'fredrikaverpil/neotest-golang',
        dependencies = {
          'leoluz/nvim-dap-go',
        },
      },
    },
    config = function()
      local neotest = require 'neotest'
      neotest.setup {
        summary = {
          animated = true,
        },
        icons = {
          expanded = '',
          child_prefix = '',
          child_indent = '',
          final_child_prefix = '',
          non_collapsible = '',
          collapsed = '',

          passed = '',
          running = '',
          failed = '',
          unknown = '',
        },
        adapters = {
          require 'neotest-golang' {
            go_test_args = {
              '-v',
              '-race',
              '-count=1',
              '-coverprofile=' .. vim.fn.getcwd() .. '/coverage.out',
            },
          },
          require 'neotest-python' {
            runner = 'pytest',
            args = { '-s' },
          },
        },
        status = { virtual_text = true },
        output = { open_on_run = true },
      }

      ---@param k string
      ---@param v string|function
      ---@param opts table
      local map = function(k, v, opts)
        vim.keymap.set('n', k, v, opts)
      end

      map('<leader>tc', neotest.run.run, { desc = 'Neo[T]est [C]lose' })
      map('<leader>td', function()
        neotest.run.run { suite = false, strategy = 'dap' }
      end, { desc = 'Neo[T]est [D]ebug' })
      map('<leader>ta', function()
        neotest.run.run(vim.fn.expand '%')
      end, { desc = 'Neo[T]est [A]ll' })
      map('<leader>to', neotest.output.open, { desc = 'Neo[T]est [O]utput' })
      map('<leader>tt', neotest.summary.toggle, { desc = 'Neo[T]est [T]oggle' })
      map('<leader>tw', neotest.watch.watch, { desc = 'Neo[T]est [W]atch' })
    end,
  },
}
