# Vector design grammar

The palette says what colors exist. This document says what *shapes* exist —
how clickables, indicators, separators, and states look on every Vector
surface, from a tmux status cell to a Helios web panel. The test for every
rule: could you learn it once and predict the rest of the system?

## 1. Shape language: angular, never round

Vector is brackets, hard edges, and underlines. The rounded powerline
half-capsule (``) is catppuccin's silhouette — Vector never uses it.

- **Fills end hard.** A filled segment is a rectangle of background color with
  a space of padding inside. No cap glyphs, no slopes, no transitions.
- **Powerline separators: none.** Between segments of equal rank there is
  either whitespace or a thin `│` divider in `base.dim`. The eye separates
  segments by color channel, not by chrome.
- **The one permitted diagonal** is the brand digraph `//`, and it appears
  only in frame titles (`VECTOR//SESSIONS`, `VECTOR//UPLINK`). It is a
  wordmark, not a separator — never use it between data segments.
- **Frames are the exception to hard edges:** popups and floats use rounded
  border lines (tmux `popup-border-lines rounded`, nvim `FloatBorder`) because
  the frame marks a *different layer*, not a segment. Layer boundaries curve;
  in-layer edges don't.

## 2. Interactive affordance: brackets mean tappable

`[ LABEL ]` is Vector's button. If it has brackets, clicking/tapping it does
something. If it doesn't, it's an indicator — looking only.

```
[ MAC ]          button: opens the session picker
[ BASE ]         button: switches to session BASE
[ ◆ HELIOS ▾ ]   button: compact rail, opens picker
 VPN✓            indicator: not bracketed, not tappable*
 CTX 47% ▓▓▓▓░   indicator: meter, read-only
```

\* the sys cluster keeps invisible click ranges for convenience, but its
*visual* contract is indicator — remediation popups are a bonus, not an
affordance we advertise. Anything whose primary purpose is to be clicked
gets brackets.

Verb glyphs refine the affordance:

- `▾` — tapping opens a picker/menu *below* the element.
- `▸` — pointer: this row is selected / drilling in happens here.
- No glyph — the button's whole label is the action (`[ BASE ]` = go there).

Buttons are UPPERCASE. Case is the second affordance channel: system nouns
and actions are uppercase (`BASE`, `MAC`, `VPN`), data and content are
lowercase (branch names, file paths, host latency). A user should be able to
squint and know which words belong to Vector and which belong to them.

## 3. State grammar

Four states, same rendering everywhere:

| State    | Recipe                                              |
|----------|-----------------------------------------------------|
| active   | **bold** + family fill (`*_bg`) + colored underline |
| inactive | `dim_neon.*` partner tone, bold, no fill            |
| pending  | family color + `…` suffix, amber if no family       |
| danger   | **bold** `neon.crimson` — the only state that shouts|

Rules that fall out of this:

- **Inactive keeps its channel.** An idle session is *dim crimson*
  (`dim_neon.crimson`), not gray — you can still read what kind of thing it
  is. Gray (`base.dim`) is reserved for content that has no channel (line
  numbers, hints, disabled).
- **The underline is the "you are here."** Colored underline (Setulc) marks
  exactly one element per collection: current window, current session,
  focused tab, root of the tree. Never underline two siblings.
- **Fill without underline = container, not selection.** Floats and popups
  sit on `panel`; the selected row inside them gets the family fill
  (`crimson_bg` in the session picker). Selection fill + pointer `▸`
  together mark the cursor row.
- **Danger never decorates.** Bold crimson appears only when something is
  wrong or destructive. It is not an accent color; that's what pink is for.

## 4. Status indicators

- **Health dot `●`** — colored by state: green up, amber transitional,
  crimson down. Compact contexts use the bare dot; wide contexts append the
  state suffix: `VPN✓`, `AWS✗`, `VPN…`. The suffix glyph carries the state
  when color can't (screenshots, colorblind, mono logs).
- **Entity mark `◆`** — an agent-bearing thing (fleet host session, an
  agent row in a picker). Always prefix, always in the entity's channel.
- **Busy `✻`** — work in progress. It is Claude's own spinner char; anything
  showing `✻` means an agent is doing something right now.
- **Meters** are exactly 10 cells of `▓`/`░`, prefixed by label and
  percentage: `CTX 47% ▓▓▓▓▓░░░░░`. Meter color escalates through the
  context channel: pink → amber ≥ 80 → crimson ≥ 95. All meters escalate;
  a meter that can't go red shouldn't be a meter.

## 5. Frames and domains

Every popup/float belongs to a domain, and the domain owns the frame color:

| Domain    | Frame color     | Title               |
|-----------|-----------------|---------------------|
| sessions  | `neon.crimson`  | ` VECTOR//SESSIONS `|
| uplink    | `neon.amber`    | ` VECTOR//UPLINK `  |
| remediate | `neon.crimson`  | ` VECTOR//VPN ` etc |
| neutral   | `base.grid`     | none                |

Titles are uppercase, space-padded, set into the top border. You know which
mode you're in before you read a row. New domains claim an unclaimed neon and
register here.

## 6. Typography and density

- Monospace everywhere; no Nerd-Font-required glyphs in the core grammar
  (everything above is plain Unicode). Nerd Font glyphs are allowed as
  *garnish* (lualine icons, lsd icons) but the system must degrade to pure
  Unicode without losing meaning.
- One space of padding inside every fill and every bracket: `[ BASE ]`,
  never `[BASE]`. Two spaces between sibling segments.
- Emphasis budget per row: at most one underline, at most one fill, bold
  freely. If a row needs more emphasis than that, split the row.

## 7. Porting checklist

Building a new Vector surface? It's compliant when:

1. Clickables are bracketed and uppercase; indicators are neither.
2. Active = bold + fill + underline; inactive = `dim_neon` partner.
3. No powerline caps; `│` or whitespace between segments; `//` only in titles.
4. Health uses `● ✓ ✗ …`, entities `◆`, busy `✻`, meters 10-cell `▓░`.
5. Frames are rounded, domain-colored, `VECTOR//DOMAIN`-titled.
6. Danger is bold crimson and nothing else is.
7. Colors come from tokens (`palette/*`), glyphs from `palette/vector.json`
   `glyphs`, rendering helpers from `lib/vector-components.sh` where shell
   is involved.

## 8. The rendering layer (metrics)

The character grid has no padding — but the *emulator that draws the grid*
does. Vertical padding, underline thickness, and underline offset are Ghostty
metrics, not tmux styles (`ghostty/config-snippet`):

- `adjust-cell-height = 35%` — vertical padding. Text centers in the taller
  cell; background fills stretch to fill it. Every fill in the system becomes
  a taller button at once.
- `adjust-underline-thickness = 2`, `adjust-underline-position = 40%` — the
  spec's 2px offset underline, rendered for real.
- Horizontal padding stays character-based: two spaces inside window tabs,
  one space each side of bracket fills (`vx_tmux_btn` handles it).
- The status bar sits on `base.void`, one layer below the terminal bg —
  fills read as raised, the rail reads as chrome.

Surfaces without metrics control (Moshi/iOS) degrade to thin underlines and
single-height cells; the grammar survives because color, brackets, and glyphs
carry the meaning — metrics only carry the polish.
