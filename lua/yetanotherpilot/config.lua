local M = {}

M.defaults = {
  provider = 'openai',
  keymap = '<leader>ce',
  split_size = 15,
  models = {
    openai = 'gpt-4o-mini',
    anthropic = 'claude-3-5-sonnet-latest',
  },
  context_lines = 5,
  session = {
    cmd = 'claude',
    args = {},
    split_size = 20,
    keymap_toggle = '<leader>cs',
    keymap_ask = '<leader>ct',
  },
}

M.options = vim.deepcopy(M.defaults)

function M.setup(opts)
  M.options = vim.tbl_deep_extend('force', vim.deepcopy(M.defaults), opts or {})
  return M.options
end

return M
