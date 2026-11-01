# The two splits

## Session mode — a real TUI, not a reimplementation

`botright 20split` + `termopen(claude)`. Text is typed in with `chansend`,
so permissions, edits and history stay Claude Code's own.

```
┌ your file ───────────────────────────────────────────────────┐
│ 41 function M.refresh()                                      │
│ 42   if not (M.buf and M.src_buf) then                       │
▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔
│ ✻ Welcome to Claude Code                                     │ ← the real
│                                                              │   CLI, whole
│ > refactor this to use async/await                           │ ← typed in by
│                                                              │   :…Ask
│ ● Read(lua/yetanotherpilot/session.lua)                      │
│   ⎿  Read 93 lines                                           │
│ Do you want to make this edit?                               │ ← its own
│   1. Yes   2. No                                             │   permission
└──────────────────────────────────────────────────────────────┘   prompt, not
                                                                   ours
```

Nothing here bypasses permissions: the plugin only opens, hides and feeds
the terminal.

```
 :YetAnotherPilotSession   toggle the split (hides, never kills)
 :YetAnotherPilotSend      the current line, or the visual selection, as-is
 :'<,'>YetAnotherPilotAsk refactor this to use async/await
                           ↑ the selection plus your instruction
 <leader>cs  toggle · <leader>ct  prefills ":YetAnotherPilotAsk " on the
 command line, in normal and visual mode
```

## Quick-ask mode — a markdown scratch buffer

`botright 15split` of a `nofile` buffer named `YetAnotherPilot`,
`filetype=markdown` so the answer renders with the user's own markdown
highlighting.

```
▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔
│ This function guards against a stale buffer before            │ ← first ask
│ refreshing: `M.buf` may have been wiped…                      │   replaces
│                                                              │   the buffer
│ ---                                                          │ ← a follow-up
│                                                              │   appends
│ Yes — `nvim_buf_is_valid` is the cheap check, and…           │   under a rule
└──────────────────────────────────────────────────────────────┘
 the buffer is non-modifiable between writes, so an answer can't be
 half-edited into something the next append contradicts
```

## Every message

```
 asking       yetanotherpilot: asking openai...            INFO
 failed       yetanotherpilot: <provider error>            ERROR
 cleared      yetanotherpilot: history cleared             INFO
 provider     yetanotherpilot: provider set to anthropic   INFO
 bad provider yetanotherpilot: unknown provider "foo"      ERROR
 no CLI       yetanotherpilot: "claude" not found on PATH  ERROR
```

The in-flight notice names the provider, because which one answers is the
one thing the split itself can't show.

## Config surface

```lua
{
  provider = 'openai',              -- quick-ask only: 'openai' | 'anthropic'
  keymap = '<leader>ce',
  split_size = 15,
  models = { openai = 'gpt-4o-mini',
             anthropic = 'claude-3-5-sonnet-latest' },
  context_lines = 5,                -- lines around the target sent as context
  session = {
    cmd = 'claude', args = {},      -- e.g. {'--permission-mode','acceptEdits'}
    split_size = 20,
    keymap_toggle = '<leader>cs',
    keymap_ask = '<leader>ct',
  },
}
```

Keys are read from `OPENAI_API_KEY` / `ANTHROPIC_API_KEY` at call time —
never written to disk or logged. Session mode uses the existing `claude`
login and needs neither.
