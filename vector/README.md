# vector

Terminal-neon design system for the VECTOR//OS family (Selene · Helios · Vector).
One canonical palette + a component grammar (`DESIGN.md`), with ports for every
surface: terminal, tmux, neovim, shell prompt, pickers, window borders,
Claude Code.

**Read `DESIGN.md` first** — it defines what clickables, buttons, indicators,
separators, meters, and frames look like. The palette is the vocabulary;
DESIGN.md is the syntax. `lib/vector-components.sh` implements the grammar as
shell functions so scripts never hand-roll segments.

## Philosophy

**Color = meaning, everywhere.** A thing keeps its channel across every tool:

| Channel  | Color            | Lives in |
|----------|------------------|----------|
| windows / active / functions | cyan `#22d3ee` | tmux window strip, nvim functions + cursor, borders, lualine normal mode |
| sessions / keywords / danger | crimson `#ff5d73` | tmux session rail, nvim keywords + errors, fzf pointer, session picker frame |
| machine / enums / warnings   | amber `#f0b429` | tmux `[ MAC ]` pill, SSH picker frame, nvim warnings, fzf match highlight |
| strings / success / health   | green `#34d399` | nvim strings, diff-add, sys-up dots |
| types / info / uplink        | blue `#60a5fa` | nvim types, SSH segment, statusline dir |
| builtins / special           | violet `#b18aff` | nvim builtins, self/this, macros |
| numbers / constants / context| pink `#e879a0` | nvim numbers, ctx meter (→ amber ≥80 → crimson ≥95), git branch in statuslines |
| regex / escapes              | ember `#ff8f5e` | nvim special chars, conflict markers |

**Active-state grammar** (same on every surface): bold + family fill +
colored underline. Inactive = desaturated family tone. Danger is the only
thing allowed to shout.

## Tokens

Canonical source: `palette/vector.json`. Everything else derives from it.

Base scale (blue-black depth ramp): `void #05080f` → `bg #0a0e17` →
`surface #0d1220` → `panel #0d1a26` → `grid #1a2332` → `overlay #2a3648` →
`selection #1c2e4a` → `dim #3d4f6b` → `comment #4d6285` → `faint #5a7290` →
`text #c8d8ea` → `bright #eaf4ff`.

Ports of the palette itself: `palette/vector.sh` (shell exports),
`palette/vector.css` (custom properties — Helios web UI), `palette/vector.lua`
(requireable table — nvim + wezterm share it).

## Integration map

Stow-friendly: each port lands where the matching gyatfiles package expects it.

| Port | File | Install |
|------|------|---------|
| ghostty | `ghostty/themes/vector` | copy to `~/.config/ghostty/themes/vector`, set `theme = vector` in ghostty config |
| ghostty metrics | `ghostty/config-snippet` | paste into main ghostty config — cell-height padding + thick offset underlines (DESIGN.md §8) |
| tmux | `tmux/vector.conf` | already deployed at `~/gyatfiles/tmux/vector.conf` (canonical copy lives here now) |
| neovim | `nvim/vector.nvim/` | see `nvim/lazyvim-snippet.lua` — add to `lua/plugins/colorscheme.lua`, sets colorscheme + lualine theme |
| fzf | `fzf/vector.zsh` | source from `~/.oh-my-zsh/custom/` (drop the file in, oh-my-zsh auto-sources `*.zsh`) |
| starship | `starship/vector.toml` | paste `[palettes.vector]` block + `palette = "vector"` + style sections into `~/.config/starship.toml` (starship has no include) |
| lsd | `lsd/themes/vector.yml` | copy to `~/.config/lsd/themes/vector.yml`, set `theme: vector` in lsd `config.yml` |
| Claude Code | `claude-code/vector-statusline.sh` | copy to `~/.claude/vector-statusline.sh`, chmod +x, merge `claude-code/settings-snippet.json` into `~/.claude/settings.json` |
| borders | `borders/bordersrc` | replaces `~/.config/borders/bordersrc` (same env-var contract, vector colors) |
| wezterm | `wezterm/vector.lua` | copy next to `wezterm.lua`, `config.color_schemes = { vector = require("vector") }` |
| components | `lib/vector-components.sh` | source from any script rendering Vector UI (tmux formats + ANSI helpers) |

### The context-meter loop

`claude-code/vector-statusline.sh` renders Claude Code's status line AND
writes the context percentage to `~/.cache/claude-ctx`. The tmux rail's
`vector-ctx.sh` segment reads that file. Install the statusline and the pink
`CTX NN% ▓▓░░` meter appears in both places from one estimator — the cig
hook can keep writing the same file if you prefer its numbers.

## Sync rules

- `palette/vector.json` is the single source of truth. Run `scripts/regen.py`
  after editing it — regenerates `palette/vector.{sh,css,lua}`, the nvim
  palette copy, and `ghostty/themes/vector`.
- `dim_neon.*` tokens are the inactive-state partners (DESIGN.md §3): inactive
  UI keeps its channel, desaturated. Derived as a 50% blend toward `base.dim`
  (crimson pinned to the shipped `#a05468`).
- Glyphs are tokens too (`glyphs` in the JSON): pointer `▸`, menu `▾`, fleet
  `◆`, health `● ✓ ✗ …`, busy `✻`, meter `▓░`, divider `│`, brand `//`.
- tmux scripts and `vector.conf` duplicate hex values by design — tmux style
  options don't reliably expand `#{@...}` custom options. Grep `VECTOR-PALETTE`
  to find every hardcoded copy when retuning.
- ANSI 16 mapping is identical in ghostty, wezterm, and nvim's
  `terminal_color_*` — terminal apps see the same world everywhere.

## Coverage notes (nvim)

`vector.nvim` covers: core editor UI, legacy syntax, full treesitter capture
set, LSP semantic tokens, diagnostics (+ virtual text on family fills), diff /
gitsigns, telescope / fzf-lua / snacks (picker · dashboard · indent ·
notifier), neo-tree / oil, nvim-cmp / blink.cmp, which-key, flash, noice,
notify, bufferline, lazy UI, trouble, treesitter-context, illuminate, grapple,
aerial, octo, neotest, render-markdown. Lualine theme ships at
`lua/lualine/themes/vector.lua` (mode colors follow the channels: normal =
cyan, insert = green, visual = pink, replace = crimson, command = amber).

Scala note (metals): semantic tokens drive most Scala highlighting — the
`@lsp.*` block is tuned so case classes hit blue, enums amber, vals-as-
constants pink. If something reads wrong in a real Scala buffer, tune the
`@lsp.typemod.*` entries first, not the treesitter captures.
