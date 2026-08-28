local M = {}

M.defaults = {
  provider = 'openai',
  keymap = '<leader>ce',
  split_size = 15,
  models = {
    openai = 'gpt-4o-mini',
    anthropic = 'claude-3-5-sonnet-latest',
    ollama = 'llama3.1',
  },
  ollama = {
    base_url = 'http://localhost:11434',
  },
  context_lines = 5,
}

M.options = vim.deepcopy(M.defaults)

function M.setup(opts)
  M.options = vim.tbl_deep_extend('force', vim.deepcopy(M.defaults), opts or {})
  return M.options
end

return M
