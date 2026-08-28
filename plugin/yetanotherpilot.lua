if vim.g.loaded_yetanotherpilot then
  return
end
vim.g.loaded_yetanotherpilot = true

vim.api.nvim_create_user_command('YetAnotherPilotExplain', function()
  require('yetanotherpilot').explain()
end, { range = true, desc = 'Explain current line or visual selection' })

vim.api.nvim_create_user_command('YetAnotherPilotClear', function()
  require('yetanotherpilot').clear()
end, { desc = 'Clear YetAnotherPilot conversation history' })

vim.api.nvim_create_user_command('YetAnotherPilotProvider', function(opts)
  require('yetanotherpilot').set_provider(opts.args)
end, { nargs = 1, desc = 'Switch YetAnotherPilot provider (openai|anthropic|ollama)' })

vim.api.nvim_create_user_command('YetAnotherPilotToggle', function()
  require('yetanotherpilot').toggle()
end, { desc = 'Toggle YetAnotherPilot split' })
