-- Peek the definition of the type under the cursor (struct/class/union/enum/typedef)
-- in a floating window, so its fields are visible without leaving the buffer.
--
-- Works on a type name (`ScreenBuffer`) or on anything that has a type
-- (`offscreen_buffer`, `state->pixels`). clangd's hover only prints
-- `struct Foo {}`, so this asks the server where the type is defined and
-- shows that source range, found with treesitter.
local M = {}

-- treesitter node types that make up a whole type definition
local type_nodes = {
  struct_specifier = true,
  class_specifier = true,
  union_specifier = true,
  enum_specifier = true,
  type_definition = true, -- typedef
  alias_declaration = true, -- using X = ...
}

local function first_location(result)
  if not result or vim.tbl_isempty(result) then
    return nil
  end
  local loc = vim.islist(result) and result[1] or result
  return {
    uri = loc.uri or loc.targetUri,
    range = loc.range or loc.targetSelectionRange,
  }
end

-- Returns the lines of the type definition at `loc`, or nil.
-- name_only: only match when `loc` is the type's own name (e.g. the result of
-- go-to-definition on `ScreenBuffer` or `u64`), not something nested inside it
-- like a field.
local function type_definition_lines(loc, encoding, name_only)
  local bufnr = vim.uri_to_bufnr(loc.uri)
  vim.fn.bufload(bufnr)

  local row = loc.range.start.line
  local line = vim.api.nvim_buf_get_lines(bufnr, row, row + 1, false)[1] or ''
  local col = vim.str_byteindex(line, encoding, loc.range.start.character, false)

  local ok, parser = pcall(vim.treesitter.get_parser, bufnr, 'cpp')
  if not ok or not parser then
    return nil
  end
  parser:parse()

  local node = parser:named_node_for_range({ row, col, row, col }, { ignore_injections = true })
  if name_only then
    local parent = node and node:parent()
    if not (node and node:type() == 'type_identifier' and parent and type_nodes[parent:type()]) then
      return nil
    end
    node = parent
  else
    while node and not type_nodes[node:type()] do
      node = node:parent()
    end
  end
  if not node then
    return nil
  end
  -- include `template <...>` for class templates
  local parent = node:parent()
  if parent and parent:type() == 'template_declaration' then
    node = parent
  end

  local start_row, start_col, end_row = node:range()
  local lines = vim.api.nvim_buf_get_lines(bufnr, start_row, end_row + 1, false)
  -- strip the definition's own indentation (e.g. nested in a function)
  local indent = start_col
  for i, l in ipairs(lines) do
    lines[i] = l:sub(1, indent):match '^%s*$' and l:sub(indent + 1) or l
  end
  if lines[#lines] and not lines[#lines]:match ';%s*$' then
    lines[#lines] = lines[#lines] .. ';'
  end

  local name = vim.fn.fnamemodify(vim.uri_to_fname(loc.uri), ':t')
  table.insert(lines, 1, string.format('// %s:%d', name, start_row + 1))
  return lines
end

local function show(lines, opts)
  local float_buf =
    vim.lsp.util.open_floating_preview(lines, 'cpp', vim.tbl_extend('force', { focus_id = 'peek_type' }, opts or {}))
  pcall(vim.treesitter.start, float_buf, 'cpp')
end

-- opts: forwarded to vim.lsp.util.open_floating_preview (border, max_width, ...)
function M.peek(opts)
  local bufnr = vim.api.nvim_get_current_buf()
  local client = vim.lsp.get_clients({ bufnr = bufnr, method = 'textDocument/typeDefinition' })[1]
  if not client then
    vim.lsp.buf.hover(opts)
    return
  end
  local encoding = client.offset_encoding
  local params = vim.lsp.util.make_position_params(0, encoding)

  -- On a type name, definition lands on that type (keeps typedefs like `u64`
  -- instead of resolving through to `uint64_t`). Otherwise use typeDefinition,
  -- which maps variables, fields and expressions to their type.
  client:request('textDocument/definition', params, function(_, def_result)
    local def_loc = first_location(def_result)
    local lines = def_loc and type_definition_lines(def_loc, encoding, true)
    if lines then
      show(lines, opts)
      return
    end
    client:request('textDocument/typeDefinition', params, function(_, type_result)
      local type_loc = first_location(type_result)
      lines = type_loc and type_definition_lines(type_loc, encoding, false)
      if lines then
        show(lines, opts)
      else
        vim.lsp.buf.hover(opts) -- not a type we can find (builtin, template param, ...)
      end
    end, bufnr)
  end, bufnr)
end

return M
