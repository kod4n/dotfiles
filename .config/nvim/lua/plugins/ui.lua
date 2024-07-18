return {
  {
    'folke/tokyonight.nvim',
    priority = 1000,
    config = function()
      require('tokyonight').setup {
        style = 'storm',
        transparent = true,
        terminal_colors = true,
        styles = {
          comments = { italic = false },
          keywords = { italic = false },
          sidebars = 'dark',
          floats = 'dark',
        },
      }
    end,
    init = function()
      vim.cmd.colorscheme 'tokyonight-night'
      vim.cmd.hi 'Comment gui=none'
    end,
  },
  { 'folke/todo-comments.nvim', event = 'VimEnter', dependencies = { 'nvim-lua/plenary.nvim' }, opts = { signs = false } },
}
