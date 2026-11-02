-- Indent settings for C/C++ buffers taken from the project's clang-format style,
-- so typing matches what clang-format will produce on save.
--
-- The style is resolved once from the cwd (nearest .clang-format, BasedOnStyle
-- expanded, clang-format defaults if there is none) and cached until the cwd
-- changes. Without clang-format on PATH the style is empty and nvim's own
-- indent settings are left alone.
--
-- vim-sleuth also sets shiftwidth/expandtab from the file's contents; for
-- clang-formatted files the two agree.
local M = {}

local style, style_cwd -- style is reloaded whenever the cwd differs from style_cwd

function M.get()
  local cwd = vim.fn.getcwd()
  if style and style_cwd == cwd then
    return style
  end
  style, style_cwd = {}, cwd
  local ok, proc = pcall(vim.system, {
    'clang-format',
    '--dump-config',
    '--assume-filename=' .. cwd .. '/x.cpp',
  }, { text = true })
  if not ok then
    return style
  end
  local out = proc:wait()
  if out.code ~= 0 then
    return style
  end
  -- only top-level scalar keys are needed, so skip the YAML parse
  for line in out.stdout:gmatch '[^\n]+' do
    local key, value = line:match '^(%w+):%s+(%S.-)%s*$'
    if key then
      style[key] = value
    end
  end
  return style
end

-- buffer options that map directly onto the style
function M.apply(bufnr)
  local s = M.get()
  local width = tonumber(s.IndentWidth)
  if width then
    vim.bo[bufnr].shiftwidth = width
    vim.bo[bufnr].softtabstop = width
  end
  local tab = tonumber(s.TabWidth)
  if tab then
    vim.bo[bufnr].tabstop = tab
  end
  if s.UseTab then
    vim.bo[bufnr].expandtab = s.UseTab == 'Never'
  end
end

function M.setup()
  -- used by after/queries/c/indents.scm to keep case labels level with the switch
  vim.treesitter.query.add_predicate('flush-case-labels?', function()
    return M.get().IndentCaseLabels == 'false'
  end, { force = true })

  -- the startup buffer's FileType fires before VimEnter changes the cwd, so
  -- reapply to the current buffer with the new directory's style
  vim.api.nvim_create_autocmd('DirChanged', {
    callback = function()
      local ft = vim.bo.filetype
      if ft == 'c' or ft == 'cpp' then
        M.apply(0)
      end
    end,
  })
end

return M
