-- Auto-show signature help (the parameter list) while the cursor is inside a
-- call's parens (or a braced initializer) in insert mode. The active parameter
-- is highlighted and follows the cursor; the popup closes when the cursor
-- leaves the call or insert mode ends.
--
-- vim.lsp.buf.signature_help() isn't used directly: calling it while its float
-- is open jumps into the float and leaves insert mode, and it never closes a
-- stale float when the server has nothing to show.
local M = {}

local ns = vim.api.nvim_create_namespace 'config.signature'
local debounce_ms = 80

-- opts: forwarded to vim.lsp.util.open_floating_preview (border, max_width, ...)
function M.attach(client, bufnr, opts)
  if not client:supports_method('textDocument/signatureHelp', bufnr) then
    return
  end

  local timer = assert(vim.uv.new_timer())
  local win = nil ---@type integer?
  local seq = 0 -- drops responses that arrive after the cursor moved again

  local function close()
    if win and vim.api.nvim_win_is_valid(win) then
      vim.api.nvim_win_close(win, true)
    end
    win = nil
  end

  local function render(result)
    local signatures = result and result.signatures or {}
    if #signatures == 0 then
      close()
      return
    end
    local idx = (result.activeSignature or 0) + 1
    local sig = signatures[idx] or signatures[1]
    sig.activeParameter = sig.activeParameter or result.activeParameter

    local triggers = vim.tbl_get(client.server_capabilities, 'signatureHelpProvider', 'triggerCharacters')
    local lines, hl =
      vim.lsp.util.convert_signature_help_to_markdown_lines({ signatures = { sig } }, vim.bo[bufnr].filetype, triggers)
    if not lines or #lines == 0 then
      close()
      return
    end

    close()
    local float_buf
    float_buf, win = vim.lsp.util.open_floating_preview(
      lines,
      'markdown',
      vim.tbl_extend('force', opts or {}, {
        focusable = false,
        focus = false,
        anchor_bias = 'above', -- keep clear of the completion menu below the cursor
        close_events = { 'InsertLeave', 'BufLeave' },
        title = #signatures > 1 and string.format(' %d/%d overloads ', idx, #signatures) or nil,
      })
    )
    if hl then
      vim.hl.range(float_buf, ns, 'LspSignatureActiveParameter', { hl[1], hl[2] }, { hl[3], hl[4] })
    end
  end

  local function request()
    if vim.api.nvim_get_current_buf() ~= bufnr or not vim.api.nvim_get_mode().mode:match '^i' then
      return
    end
    seq = seq + 1
    local this_seq = seq
    local params = vim.lsp.util.make_position_params(0, client.offset_encoding)
    client:request('textDocument/signatureHelp', params, function(err, result)
      if this_seq ~= seq or not vim.api.nvim_get_mode().mode:match '^i' then
        return
      end
      if err then
        close()
        return
      end
      render(result)
    end, bufnr)
  end

  local group = vim.api.nvim_create_augroup(string.format('config.signature.%d.%d', bufnr, client.id), { clear = true })
  vim.api.nvim_create_autocmd({ 'InsertEnter', 'CursorMovedI' }, {
    group = group,
    buffer = bufnr,
    callback = function()
      timer:stop()
      timer:start(debounce_ms, 0, vim.schedule_wrap(request))
    end,
  })
  vim.api.nvim_create_autocmd({ 'InsertLeave', 'BufLeave' }, {
    group = group,
    buffer = bufnr,
    callback = function()
      timer:stop()
      seq = seq + 1
      close()
    end,
  })
  vim.api.nvim_create_autocmd('LspDetach', {
    group = group,
    buffer = bufnr,
    callback = function(event)
      if event.data.client_id == client.id then
        timer:stop()
        timer:close()
        close()
        vim.api.nvim_del_augroup_by_id(group)
      end
    end,
  })
end

return M
