return {
  {
    'nvim-neotest/neotest',
    dependencies = {
      'nvim-neotest/nvim-nio',
      'nvim-lua/plenary.nvim',
      'antoinemadec/FixCursorHold.nvim',
      'nvim-treesitter/nvim-treesitter',
      'marilari88/neotest-vitest',
      'nvim-neotest/neotest-plenary',
      { 'fredrikaverpil/neotest-golang', branch = 'windows' },
    },
    config = function()
      local neotest = require 'neotest'
      neotest.setup {
        adapters = {
          require 'neotest-golang' {
            go_test_args = {
              '-v',
              '-race',
              '-coverprofile=' .. vim.fn.getcwd() .. '/coverage.out',
            },
            runner = 'gotestsum',
          },
        },
      }

      ---@param k string
      ---@param v string|function
      ---@param opts table
      local map = function(k, v, opts)
        vim.keymap.set('n', k, v, opts)
      end

      map('<leader>tc', neotest.run.run, { desc = 'Neo[T]est [C]lose' })
      map('<leader>ta', function()
        neotest.run.run(vim.fn.expand '%')
      end, { desc = 'Neo[T]est [A]ll' })
      map('<leader>to', neotest.output.open, { desc = 'Neo[T]est [O]utput' })
      map('<leader>tt', neotest.summary.toggle, { desc = 'Neo[T]est [T]oggle' })
      map('<leader>tw', neotest.watch.watch, { desc = 'Neo[T]est [W]atch' })
    end,
  },
}
