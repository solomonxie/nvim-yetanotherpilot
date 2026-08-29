local config = require('yetanotherpilot.config')

local M = {}

local adapters = {
  openai = 'yetanotherpilot.providers.openai',
  anthropic = 'yetanotherpilot.providers.anthropic',
}

-- complete(messages, on_done) — dispatches to the configured provider.
function M.complete(messages, on_done)
  local provider = config.options.provider
  local mod_path = adapters[provider]
  if not mod_path then
    on_done(string.format('Unknown provider: %s', tostring(provider)), nil)
    return
  end
  local adapter = require(mod_path)
  local model = config.options.models[provider]
  adapter.complete(messages, { model = model }, on_done)
end

function M.set_provider(name)
  if not adapters[name] then
    vim.notify('yetanotherpilot: unknown provider "' .. name .. '"', vim.log.levels.ERROR)
    return false
  end
  config.options.provider = name
  return true
end

return M
