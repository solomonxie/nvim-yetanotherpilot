local config = require('yetanotherpilot.config')

local M = {}

M.bufnr = nil
M.winnr = nil

local function ensure_buf()
  if M.bufnr and vim.api.nvim_buf_is_valid(M.bufnr) then
    return M.bufnr
  end
  M.bufnr = vim.api.nvim_create_buf(false, true)
  vim.bo[M.bufnr].filetype = 'markdown'
  vim.bo[M.bufnr].buftype = 'nofile'
  vim.bo[M.bufnr].bufhidden = 'hide'
  vim.bo[M.bufnr].swapfile = false
  vim.api.nvim_buf_set_name(M.bufnr, 'YetAnotherPilot')
  return M.bufnr
end

local function ensure_win()
  if M.winnr and vim.api.nvim_win_is_valid(M.winnr) then
    return M.winnr
  end
  local bufnr = ensure_buf()
  vim.cmd(string.format('botright %dsplit', config.options.split_size))
  M.winnr = vim.api.nvim_get_current_win()
  vim.api.nvim_win_set_buf(M.winnr, bufnr)
  return M.winnr
end

function M.is_open()
  return M.winnr ~= nil and vim.api.nvim_win_is_valid(M.winnr)
end

function M.toggle()
  if M.is_open() then
    vim.api.nvim_win_close(M.winnr, true)
    M.winnr = nil
  else
    ensure_win()
  end
end

-- Replaces buffer contents with `text` (new top-level explain call).
function M.show(text)
  local bufnr = ensure_buf()
  ensure_win()
  local lines = vim.split(text, '\n', { plain = true })
  vim.bo[bufnr].modifiable = true
  vim.api.nvim_buf_set_lines(bufnr, 0, -1, false, lines)
  vim.bo[bufnr].modifiable = false
end

-- Appends `text` to the buffer (follow-up within same history).
function M.append(text)
  local bufnr = ensure_buf()
  ensure_win()
  local lines = vim.split('\n---\n\n' .. text, '\n', { plain = true })
  vim.bo[bufnr].modifiable = true
  vim.api.nvim_buf_set_lines(bufnr, -1, -1, false, lines)
  vim.bo[bufnr].modifiable = false
end

return M
