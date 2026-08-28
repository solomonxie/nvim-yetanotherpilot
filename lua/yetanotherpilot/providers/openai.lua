local curl = require('plenary.curl')

local M = {}

-- complete(messages, opts, on_done)
-- opts: { model = string }
-- on_done(err, text)
function M.complete(messages, opts, on_done)
  local api_key = vim.env.OPENAI_API_KEY
  if not api_key or api_key == '' then
    on_done('OPENAI_API_KEY is not set', nil)
    return
  end

  curl.post('https://api.openai.com/v1/chat/completions', {
    headers = {
      ['Authorization'] = 'Bearer ' .. api_key,
      ['Content-Type'] = 'application/json',
    },
    body = vim.fn.json_encode({
      model = opts.model,
      messages = messages,
    }),
    callback = vim.schedule_wrap(function(response)
      if response.status ~= 200 then
        on_done(string.format('OpenAI API error (%d): %s', response.status, response.body), nil)
        return
      end
      local ok, decoded = pcall(vim.fn.json_decode, response.body)
      if not ok then
        on_done('Failed to decode OpenAI response', nil)
        return
      end
      local choice = decoded.choices and decoded.choices[1]
      local text = choice and choice.message and choice.message.content
      if not text then
        on_done('Unexpected OpenAI response shape', nil)
        return
      end
      on_done(nil, text)
    end),
  })
end

return M
