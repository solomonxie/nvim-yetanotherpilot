local curl = require('plenary.curl')

local M = {}

-- complete(messages, opts, on_done)
-- opts: { model = string }
-- on_done(err, text)
function M.complete(messages, opts, on_done)
  local api_key = vim.env.ANTHROPIC_API_KEY
  if not api_key or api_key == '' then
    on_done('ANTHROPIC_API_KEY is not set', nil)
    return
  end

  curl.post('https://api.anthropic.com/v1/messages', {
    headers = {
      ['x-api-key'] = api_key,
      ['anthropic-version'] = '2023-06-01',
      ['Content-Type'] = 'application/json',
    },
    body = vim.fn.json_encode({
      model = opts.model,
      max_tokens = opts.max_tokens or 1024,
      messages = messages,
    }),
    callback = vim.schedule_wrap(function(response)
      if response.status ~= 200 then
        on_done(string.format('Anthropic API error (%d): %s', response.status, response.body), nil)
        return
      end
      local ok, decoded = pcall(vim.fn.json_decode, response.body)
      if not ok then
        on_done('Failed to decode Anthropic response', nil)
        return
      end
      local block = decoded.content and decoded.content[1]
      local text = block and block.text
      if not text then
        on_done('Unexpected Anthropic response shape', nil)
        return
      end
      on_done(nil, text)
    end),
  })
end

return M
