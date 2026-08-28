local config = require('yetanotherpilot.config')
local context = require('yetanotherpilot.context')
local history = require('yetanotherpilot.history')
local ui = require('yetanotherpilot.ui')
local providers = require('yetanotherpilot.providers')

local M = {}

function M.setup(opts)
  config.setup(opts)

  vim.keymap.set({ 'n', 'v' }, config.options.keymap, M.explain, { desc = 'YetAnotherPilot: explain' })
end

-- Explains the current line or visual selection. A follow-up call (when the
-- split is already open and history is non-empty) appends to the same
-- conversation instead of starting a fresh one.
function M.explain()
  local ctx = context.gather()
  local prompt = context.build_prompt(ctx)
  local is_followup = ui.is_open() and #history.get() > 0

  history.add('user', prompt)
  vim.notify('yetanotherpilot: asking ' .. config.options.provider .. '...', vim.log.levels.INFO)

  providers.complete(history.get(), function(err, text)
    if err then
      vim.notify('yetanotherpilot: ' .. err, vim.log.levels.ERROR)
      return
    end
    history.add('assistant', text)
    if is_followup then
      ui.append(text)
    else
      ui.show(text)
    end
  end)
end

function M.clear()
  history.clear()
  vim.notify('yetanotherpilot: history cleared', vim.log.levels.INFO)
end

function M.set_provider(name)
  if providers.set_provider(name) then
    M.clear()
    vim.notify('yetanotherpilot: provider set to ' .. name, vim.log.levels.INFO)
  end
end

function M.toggle()
  ui.toggle()
end

return M
