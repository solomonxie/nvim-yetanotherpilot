# nvim-yetanotherpilot

Explain-line Neovim plugin. Calls provider HTTP APIs directly — no local
`claude` CLI subprocess, no cross-instance state. Supports OpenAI (default),
Anthropic, and Ollama.

## Requirements

- Neovim >= 0.8
- [plenary.nvim](https://github.com/nvim-lua/plenary.nvim)

## Install (vim-plug)

```vim
Plug 'nvim-lua/plenary.nvim'
Plug 'solomonxie/nvim-yetanotherpilot'
```

```lua
require('yetanotherpilot').setup({
  provider = 'openai',        -- 'openai' | 'anthropic' | 'ollama'
  keymap = '<leader>ce',
})
```

## API keys

Read only from environment variables at call time — never written to disk,
logged, or committed.

| Provider  | Env var             |
|-----------|----------------------|
| openai    | `OPENAI_API_KEY`    |
| anthropic | `ANTHROPIC_API_KEY` |
| ollama    | none (local server)  |

## Commands

- `:YetAnotherPilotExplain` — explain current line, or visual selection if active.
- `:YetAnotherPilotClear` — clear conversation history.
- `:YetAnotherPilotProvider <name>` — switch provider at runtime (`openai`, `anthropic`, `ollama`).
- `:YetAnotherPilotToggle` — toggle the explanation split.

Default keymap `<leader>ce` (normal and visual mode) runs `:YetAnotherPilotExplain`.

## Config defaults

```lua
{
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
```

## Ollama

Requires a running local server (`ollama serve`) with a pulled model
(`ollama pull llama3.1`). `ollama.base_url` can point at a remote host.
