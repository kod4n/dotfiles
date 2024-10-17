return {
  { 'numToStr/Comment.nvim', opts = {} },
  -- { 'luk400/vim-jukit' },
  {
    'dccsillag/magma-nvim',
    version = '*',
    run = 'UpdateRemotePlugins',
    lazy = false,
    keys = {
      { '<leader>mi', '<cmd>MagmaInit<CR>', desc = 'This command initializes a runtime for the current buffer.' },
      { '<leader>mo', '<cmd>MagmaEvaluateOperator<CR>', desc = 'Evaluate the text given by some operator.' },
      { '<leader>ml', '<cmd>MagmaEvaluateLine<CR>', desc = 'Evaluate the current line.' },
      { '<leader>mv', '<cmd>MagmaEvaluateVisual<CR>', desc = 'Evaluate the selected text.' },
      { '<leader>mc', '<cmd>MagmaEvaluateOperator<CR>', desc = 'Reevaluate the currently selected cell.' },
      { '<leader>mr', '<cmd>MagmaRestart!<CR>', desc = 'Shuts down and restarts the current kernel.' },
      {
        '<leader>mx',
        '<cmd>MagmaInterrupt<CR>',
        desc = 'Interrupts the currently running cell and does nothing if not cell is running.',
      },
    },
  },
  {
    'folke/trouble.nvim',
    opts = {}, -- for default options, refer to the configuration section for custom setup.
    cmd = 'Trouble',
    keys = {
      {
        '<leader>xx',
        '<cmd>Trouble diagnostics toggle<cr>',
        desc = 'Diagnostics (Trouble)',
      },
      {
        '<leader>xX',
        '<cmd>Trouble diagnostics toggle filter.buf=0<cr>',
        desc = 'Buffer Diagnostics (Trouble)',
      },
      {
        '<leader>cs',
        '<cmd>Trouble symbols toggle focus=false<cr>',
        desc = 'Symbols (Trouble)',
      },
      {
        '<leader>cl',
        '<cmd>Trouble lsp toggle focus=false win.position=right<cr>',
        desc = 'LSP Definitions / references / ... (Trouble)',
      },
      {
        '<leader>xL',
        '<cmd>Trouble loclist toggle<cr>',
        desc = 'Location List (Trouble)',
      },
      {
        '<leader>xQ',
        '<cmd>Trouble qflist toggle<cr>',
        desc = 'Quickfix List (Trouble)',
      },
    },
  },
}
