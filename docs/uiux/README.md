# UI/UX mockups — Yet Another Pilot

> The plugin itself is WIP. These drawings are of what exists in the code
> today, not of a finished product.

Two surfaces, both bottom splits: a live `claude` terminal (session mode)
and a markdown scratch buffer (quick-ask mode).

Glyphs follow the `uiux` skill (`references/notation.md` + `text-figma.md`):
`▔▔▔` window border · `←` annotation · `⟳` working.

## Surface map

```
 any buffer / visual selection
   ├ <leader>cs  :YetAnotherPilotSession  ─▶ terminal split, real claude TUI
   │   :YetAnotherPilotSend               ─▶ types the line/selection into it
   │   <leader>ct  :YetAnotherPilotAsk …  ─▶ prefills the command line
   └ <leader>ce  :YetAnotherPilotExplain  ─▶ markdown split, single-turn
       :YetAnotherPilotToggle · Clear · Provider <name>
```

## Files

| File | Covers |
|---|---|
| `splits.md` | both splits, the command surface, and every message |
