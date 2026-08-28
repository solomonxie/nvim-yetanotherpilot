local config = require('yetanotherpilot.config')

-- Interactive `claude` CLI session in a terminal split. Text is typed into
-- the real TUI via chansend, so tool permissions, file edits, and history
-- are all handled natively by Claude Code itself — this module only owns
-- spawning/showing/hiding the terminal and feeding it input.
local M = {}

M.bufnr = nil
M.winnr = nil
M.job_id = nil

local function clear_state()
  M.job_id = nil
  M.bufnr = nil
  M.winnr = nil
end

local function open_win()
  vim.cmd(string.format('botright %dsplit', config.options.session.split_size))
  M.winnr = vim.api.nvim_get_current_win()
  vim.api.nvim_win_set_buf(M.winnr, M.bufnr)
end

-- Ensures the session job + window exist, spawning if needed. Returns
-- (job_id, was_cold_spawn) or (nil, false) if `claude` isn't executable.
function M.ensure()
  if M.job_id and M.bufnr and vim.api.nvim_buf_is_valid(M.bufnr) then
    if not (M.winnr and vim.api.nvim_win_is_valid(M.winnr)) then
      open_win()
    end
    return M.job_id, false
  end

  local cmd_name = config.options.session.cmd
  if vim.fn.executable(cmd_name) ~= 1 then
    vim.notify('yetanotherpilot: "' .. cmd_name .. '" not found on PATH', vim.log.levels.ERROR)
    return nil, false
  end

  vim.cmd(string.format('botright %dsplit', config.options.session.split_size))
  M.winnr = vim.api.nvim_get_current_win()

  local cmd = { cmd_name }
  vim.list_extend(cmd, config.options.session.args or {})
  M.job_id = vim.fn.termopen(cmd, {
    on_exit = clear_state,
  })
  M.bufnr = vim.api.nvim_get_current_buf()

  return M.job_id, true
end

function M.is_open()
  return M.winnr ~= nil and vim.api.nvim_win_is_valid(M.winnr)
end

function M.toggle()
  if M.is_open() then
    vim.api.nvim_win_close(M.winnr, false)
    M.winnr = nil
  else
    M.ensure()
    vim.cmd('startinsert')
  end
end

-- Sends `text` into the session, spawning it first if needed. Wraps in
-- bracketed paste so embedded newlines land as literal text instead of
-- the TUI treating them as pressing Enter (premature submit).
function M.send(text)
  local job_id, cold = M.ensure()
  if not job_id then
    return
  end

  local payload = '\27[200~' .. text .. '\27[201~\r'
  local function do_send()
    vim.fn.chansend(job_id, payload)
    if M.winnr and vim.api.nvim_win_is_valid(M.winnr) then
      vim.api.nvim_set_current_win(M.winnr)
      vim.cmd('startinsert')
    end
  end

  if cold then
    vim.defer_fn(do_send, 300)
  else
    do_send()
  end
end

return M
