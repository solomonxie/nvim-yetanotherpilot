local config = require('yetanotherpilot.config')

local M = {}

local function visual_selection()
  local mode = vim.fn.mode()
  if mode ~= 'v' and mode ~= 'V' and mode ~= '\22' then
    return nil
  end
  local start_pos = vim.fn.getpos('v')
  local end_pos = vim.fn.getpos('.')
  local start_line = math.min(start_pos[2], end_pos[2])
  local end_line = math.max(start_pos[2], end_pos[2])
  local lines = vim.api.nvim_buf_get_lines(0, start_line - 1, end_line, false)
  return table.concat(lines, '\n'), start_line, end_line
end

-- Gathers the target text (visual selection or current line) plus
-- surrounding context and filetype, for building the prompt.
function M.gather()
  local bufnr = vim.api.nvim_get_current_buf()
  local filetype = vim.bo[bufnr].filetype

  local target, start_line, end_line = visual_selection()
  if not target then
    local lnum = vim.api.nvim_win_get_cursor(0)[1]
    target = vim.api.nvim_buf_get_lines(bufnr, lnum - 1, lnum, false)[1] or ''
    start_line, end_line = lnum, lnum
  end

  local ctx_n = config.options.context_lines or 5
  local total_lines = vim.api.nvim_buf_line_count(bufnr)
  local before_start = math.max(0, start_line - 1 - ctx_n)
  local after_end = math.min(total_lines, end_line + ctx_n)

  local before = vim.api.nvim_buf_get_lines(bufnr, before_start, start_line - 1, false)
  local after = vim.api.nvim_buf_get_lines(bufnr, end_line, after_end, false)

  return {
    filetype = filetype,
    target = target,
    before = table.concat(before, '\n'),
    after = table.concat(after, '\n'),
  }
end

-- Builds a single user-role prompt string from gathered context.
function M.build_prompt(ctx)
  local parts = {
    string.format('Explain the following %s code.', ctx.filetype ~= '' and ctx.filetype or 'code'),
  }
  if ctx.before ~= '' then
    table.insert(parts, '\nContext before:\n```\n' .. ctx.before .. '\n```')
  end
  table.insert(parts, '\nCode to explain:\n```\n' .. ctx.target .. '\n```')
  if ctx.after ~= '' then
    table.insert(parts, '\nContext after:\n```\n' .. ctx.after .. '\n```')
  end
  return table.concat(parts, '\n')
end

return M
