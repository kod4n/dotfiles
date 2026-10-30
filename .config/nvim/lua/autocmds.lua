vim.api.nvim_create_autocmd('TextYankPost', {
  desc = 'Highlight when yanking (copying) text',
  group = vim.api.nvim_create_augroup('highlight-yank', { clear = true }),
  callback = function()
    vim.highlight.on_yank()
  end,
})

vim.api.nvim_create_autocmd('VimEnter', {
  desc = 'Set working directory to the file opened on startup',
  callback = function()
    local buffer_name = vim.api.nvim_buf_get_name(0)
    if buffer_name == '' then
      return
    end

    local path = vim.fs.normalize(buffer_name)

    if vim.fn.isdirectory(path) == 1 then
      vim.api.nvim_set_current_dir(path)
    elseif path ~= '' and vim.fn.filereadable(path) == 1 then
      local initial_dir = vim.fn.expand '%:p:h'
      vim.api.nvim_set_current_dir(initial_dir)
    end
  end,
})
