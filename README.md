# Yet Another Pilot

Interact with a Claude Code session — or another LLM provider — directly
from Neovim. Hand the agent a repo-wide task, ask a quick question about
the current line, or send it a selection with instructions.

## Requirements

- Neovim >= 0.8
- [plenary.nvim](https://github.com/nvim-lua/plenary.nvim)
- [Claude Code](https://claude.com/claude-code) CLI on PATH, for session mode

## Install (vim-plug)

```vim
Plug 'nvim-lua/plenary.nvim'
Plug 'solomonxie/nvim-yetanotherpilot'
```

```lua
require('yetanotherpilot').setup({
  provider = 'openai',        -- quick-ask provider: 'openai' | 'anthropic' | 'ollama'
  keymap = '<leader>ce',
})
```

## Session mode

A real, interactive `claude` CLI session running in a terminal split. Text
sent to it is typed straight into the live TUI, so tool permissions, file
edits, and conversation history are all handled natively by Claude Code
itself — nothing here bypasses permissions by default.

- `:YetAnotherPilotSession` — toggle the session split.
- `:YetAnotherPilotSend` — send the current line/selection as-is.
- `:YetAnotherPilotAsk {task}` — send the current line/selection with a
  task, e.g. `:'<,'>YetAnotherPilotAsk refactor this to use async/await`.

Default keymaps: `<leader>cs` toggles the session, `<leader>ct` (normal and
visual) prefills `:YetAnotherPilotAsk ` on the command line.

## Quick-ask mode

Stateless, single-turn calls to OpenAI, Anthropic, or Ollama — for a fast
answer without spinning up a full session.

- `:YetAnotherPilotExplain` — explain current line, or visual selection if active.
- `:YetAnotherPilotClear` — clear conversation history.
- `:YetAnotherPilotProvider <name>` — switch provider at runtime (`openai`, `anthropic`, `ollama`).
- `:YetAnotherPilotToggle` — toggle the quick-ask split.

Default keymap `<leader>ce` (normal and visual mode) runs `:YetAnotherPilotExplain`.

## API keys

Read only from environment variables at call time — never written to disk,
logged, or committed. Session mode uses your existing `claude` login; only
quick-ask mode needs these.

| Provider  | Env var             |
|-----------|----------------------|
| openai    | `OPENAI_API_KEY`    |
| anthropic | `ANTHROPIC_API_KEY` |
| ollama    | none (local server)  |

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
  session = {
    cmd = 'claude',
    args = {},                    -- e.g. {'--permission-mode', 'acceptEdits'}
    split_size = 20,
    keymap_toggle = '<leader>cs',
    keymap_ask = '<leader>ct',
  },
}
```

## Ollama

Requires a running local server (`ollama serve`) with a pulled model
(`ollama pull llama3.1`). `ollama.base_url` can point at a remote host.
