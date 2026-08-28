local curl = require('plenary.curl')
local config = require('yetanotherpilot.config')

local M = {}

-- complete(messages, opts, on_done)
-- opts: { model = string }
-- on_done(err, text)
function M.complete(messages, opts, on_done)
  local base_url = config.options.ollama.base_url or 'http://localhost:11434'

  curl.post(base_url .. '/api/chat', {
    headers = {
      ['Content-Type'] = 'application/json',
    },
    body = vim.fn.json_encode({
      model = opts.model,
      messages = messages,
      stream = false,
    }),
    callback = vim.schedule_wrap(function(response)
      if response.status ~= 200 then
        on_done(string.format('Ollama error (%d): %s', response.status, response.body), nil)
        return
      end
      local ok, decoded = pcall(vim.fn.json_decode, response.body)
      if not ok then
        on_done('Failed to decode Ollama response', nil)
        return
      end
      local text = decoded.message and decoded.message.content
      if not text then
        on_done('Unexpected Ollama response shape', nil)
        return
      end
      on_done(nil, text)
    end),
  })
end

return M
