#!/usr/bin/env bash
# vector statusline for Claude Code — POWERLINE variant (DESIGN.md §9).
# Slant-separated fills:
#   ◆ OPUS 4.8 ╱ helios ╱  main ╱ CTX 47% ▓▓▓▓░░░░░░ ╱ $0.42
#   cyan fill    blue fill  panel+pink  grid+escalation   void+faint
# Requires a Nerd Font (slant glyphs E0BC/E0B8). The plain variant
# (vector-statusline.sh) is the degrade path — identical data, no fills.
#
# Same side effect as the plain variant: writes ctx % to ~/.cache/claude-ctx
# for the tmux rail. Same defensive parsing; every segment optional.
#
# Install (in ~/.claude/settings.json):
#   "statusLine": { "type": "command", "command": "~/.claude/vector-statusline-powerline.sh" }
set -u

# VECTOR-PALETTE (keep in sync with palette/vector.json)
BG="#0a0e17";    VOID="#05080f";  PANEL="#0d1a26"; GRID="#1a2332"
FAINT="#5a7290"; CYAN="#22d3ee";  BLUE="#60a5fa";  PINK="#e879a0"
AMBER="#f0b429"; CRIMSON="#ff5d73"

# Separator: NF powerline-extra slant U+E0BC, embedded as raw UTF-8 bytes
# (bash 3.2 has no \u escapes). Swap bytes to \xee\x82\xb0 (U+E0B0, classic
# arrow) if you ever want the arrow look — per DESIGN.md §9, slants only.
SEP=$(printf '\xee\x82\xbc')

fgc() { local h=${1#\#}; printf '38;2;%d;%d;%d' "0x${h:0:2}" "0x${h:2:2}" "0x${h:4:2}"; }
bgc() { local h=${1#\#}; printf '48;2;%d;%d;%d' "0x${h:0:2}" "0x${h:2:2}" "0x${h:4:2}"; }

pl_prev=""
pl_seg() { # pl_seg <bg> <fg> <text> [nobold]
  local bg=$1 fg=$2 text=$3 weight="1"
  [ "${4:-}" = "nobold" ] && weight="22"
  if [ -n "$pl_prev" ]; then
    printf '\033[0m\033[%s;%sm%s' "$(fgc "$pl_prev")" "$(bgc "$bg")" "$SEP"
  fi
  printf '\033[%s;%s;%sm %s ' "$(fgc "$fg")" "$(bgc "$bg")" "$weight" "$text"
  pl_prev=$bg
}
pl_end() {
  [ -n "$pl_prev" ] || return 0
  printf '\033[0m\033[%sm%s\033[0m' "$(fgc "$pl_prev")" "$SEP"
}

input=$(cat)
have_jq=0
command -v jq >/dev/null 2>&1 && have_jq=1
jqget() {
  [ "$have_jq" -eq 1 ] || { echo ""; return; }
  printf '%s' "$input" | jq -r "$1 // empty" 2>/dev/null
}

# ── model: cyan fill, dark text ──────────────────────────────────
model=$(jqget '.model.display_name')
[ -z "$model" ] && model=$(jqget '.model.id')
[ -z "$model" ] && model="CLAUDE"
model=$(printf '%s' "$model" | tr '[:lower:]' '[:upper:]' | sed 's/^CLAUDE //')
pl_seg "$CYAN" "$BG" "◆ $model"

# ── directory: blue fill, dark text ──────────────────────────────
dir=$(jqget '.workspace.current_dir')
[ -z "$dir" ] && dir=$(jqget '.cwd')
[ -n "$dir" ] && pl_seg "$BLUE" "$BG" "${dir##*/}"

# ── git branch: panel fill, pink text ────────────────────────────
if [ -n "$dir" ] && command -v git >/dev/null 2>&1; then
  branch=$(git -C "$dir" branch --show-current 2>/dev/null)
  [ -n "$branch" ] && pl_seg "$PANEL" "$PINK" " $branch"
fi

# ── context tokens: grid fill, escalating text color ─────────────
# Real usage (input + cache_creation + cache_read) from the transcript's last
# assistant turn — accurate, unlike the old byte-size pct and cost segments
# (both dropped). NNNk/200k, escalating pink -> amber >=80% -> crimson >=95%.
transcript=$(jqget '.transcript_path')
if [ -n "$transcript" ] && [ -f "$transcript" ] && [ "$have_jq" -eq 1 ]; then
  ctx=$(jq -s '[.[]|select(.message.usage)]|last|.message.usage
    |(.input_tokens+(.cache_creation_input_tokens//0)+(.cache_read_input_tokens//0))' \
    "$transcript" 2>/dev/null)
  if [ -n "$ctx" ] && [ "$ctx" -gt 0 ] 2>/dev/null; then
    if [ "$ctx" -ge 1000 ]; then tok="$((ctx / 1000))k"; else tok="$ctx"; fi
    pctwin=$(( ctx * 100 / 200000 ))
    color=$PINK
    [ "$pctwin" -ge 80 ] && color=$AMBER
    [ "$pctwin" -ge 95 ] && color=$CRIMSON
    pl_seg "$GRID" "$color" "${tok}/200k"
    mkdir -p "$HOME/.cache" 2>/dev/null
    printf '%s' "$ctx" > "$HOME/.cache/claude-ctx" 2>/dev/null
  fi
fi

pl_end
