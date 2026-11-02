return {
  border = {
    { '╭', 'FloatBorder' },
    { '─', 'FloatBorder' },
    { '╮', 'FloatBorder' },
    { '│', 'FloatBorder' },
    { '╯', 'FloatBorder' },
    { '─', 'FloatBorder' },
    { '╰', 'FloatBorder' },
    { '│', 'FloatBorder' },
  },
  -- bg NONE so the border cells (incl. the area outside the rounded corners)
  -- show the transparent editor background instead of a dark block.
  float_border = {
    fg = '#7aa2f7',
    bg = 'NONE',
  },
  normal_border = {
    fg = '#c0caf5',
    bg = '#16161e',
  },
}
