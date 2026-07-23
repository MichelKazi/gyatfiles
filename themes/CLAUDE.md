# themes/ — agent instructions

Shared theme system for the dotfiles. Currently one theme: `vector` (VECTOR//OS
design system). Every tool that has a color/theme derives from a single source
of truth here — no tool hand-holds its own palette.

## The one rule

**`themes/vector/palette/vector.json` is the source of truth. Everything else is
derived.** To retune a color, edit the JSON, then run the generator:

```sh
python3 themes/vector/scripts/regen.py
```

Never hand-edit a generated file. Never copy a color value between tools by hand.
If two surfaces disagree on a color, the JSON wins and regen fixes them.

## Layout

```
themes/vector/
  palette/vector.json        ← SOURCE OF TRUTH. canonical tokens.
  palette/vector.{sh,css,lua} ← GENERATED ports of the palette
  scripts/regen.py           ← rebuilds every derived file from vector.json
  DESIGN.md                  ← the component grammar (clickables, meters, frames…)
  README.md                  ← philosophy + channel→color table
  lib/vector-components.sh   ← shell fns implementing the grammar
  nvim/vector.nvim/          ← the neovim colorscheme plugin
  tmux/ ghostty/ lsd/ fzf/ wezterm/ starship/ borders/ claude-code/
                             ← per-tool ports (see wiring below)
```

## How each config consumes the theme

Configs live in their own stow dirs and reach into `themes/vector/` three ways.
When you add a tool, pick the highest-fidelity option it supports:

**A. Load by path** (tool reads an explicit file path — best, zero duplication):
- tmux: `.tmux.macos.conf` / `.tmux.steamos.conf` →
  `source-file ~/gyatfiles/themes/vector/tmux/vector.conf`
- nvim: `colorscheme.lua` → `dir = ~/gyatfiles/themes/vector/nvim/vector.nvim`

**B. Relative symlink** (tool only loads from its OWN config dir — symlink the
stowed file into `themes/vector/`; relative so it survives stow + ports to
arch/steamos with no hardcoded user path):
- `wezterm/.config/wezterm/vector.lua`     → `themes/vector/wezterm/vector.lua`
- `zsh/.oh-my-zsh/custom/vector.zsh`        → `themes/vector/fzf/vector.zsh`
- `ghostty/.config/ghostty/themes/vector`   → `themes/vector/ghostty/themes/vector`
- `lsd/.config/lsd/themes/vector.yml`        → `themes/vector/lsd/themes/vector.yml`
- `borders/.config/borders/bordersrc`        → `themes/vector/borders/bordersrc`

**C. Generated-in-place** (tool has NO include/import mechanism — regen splices
the palette between marker comments):
- starship: `starship.toml` holds `[palettes.vector]` between
  `# VECTOR-PALETTE-START` / `# VECTOR-PALETTE-END`. regen.py rewrites that block
  from vector.json. Everything outside the markers is hand-maintained styling.

## Adding / changing a color

1. Edit `palette/vector.json`.
2. `python3 themes/vector/scripts/regen.py`.
3. Class-B tools update for free (symlinks). Class-A tools reload on next launch.
   Class-C (starship) is rewritten by regen.
4. Hand-maintained ports NOT yet generated — `tmux/vector.conf`, tmux runtime
   scripts, `lib/vector-components.sh`, `wezterm/vector.lua`, `lsd/themes/vector.yml`,
   `borders/bordersrc`, claude-code statuslines — carry a `VECTOR-PALETTE` grep
   marker in their headers. Grep for it and update by hand, or (better) extend
   regen.py to generate them.

## Verifying a change

- `python3 themes/vector/scripts/regen.py` must run clean and print the surfaces
  it regenerated.
- After regen, `git diff` should show ONLY intended color changes. A generator
  that dirties a file it shouldn't = a bug in regen.py.
- Mutation check when touching regen.py: perturb one value in vector.json, regen,
  confirm the target file reflects it, then revert. A generated file that stays
  put when you change its source is not actually generated.

## Adding a new theme

Same shape: `themes/<name>/palette/<name>.json` + a regen script. Keep the palette
as the only hand-edited file. Don't fork the vector structure unless the new theme
needs a different grammar — reuse `regen.py` conventions.
