-- In-memory per-nvim-instance conversation history. No persistence,
-- no cross-instance sharing.
local M = {}

M.messages = {}

function M.add(role, content)
  table.insert(M.messages, { role = role, content = content })
end

function M.get()
  return M.messages
end

function M.clear()
  M.messages = {}
end

return M
