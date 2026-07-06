#!/usr/bin/env bash
# vector statusline for Claude Code.
# Renders:  ◆ OPUS 4.8 │ [ dirname ] │  branch │ CTX 47% ▓▓▓▓░░░░░░ │ $0.42
# Channels: model = cyan, dir = blue brackets (machine-adjacent), branch =
# pink, ctx meter = pink -> amber >=80 -> crimson >=95, cost = faint.
#
# Side effect: writes the ctx percentage to ~/.cache/claude-ctx so the tmux
# rail's vector-ctx.sh segment lights up for free — one estimator, two
# surfaces. (Same transcript-size heuristic as the cig hook: bytes/3.8 chars
# per token against a ~160k usable window. Crude but monotonic, which is all
# a burn-down meter needs.)
#
# Install (in ~/.claude/settings.json):
#   "statusLine": { "type": "command", "command": "~/.claude/vector-statusline.sh" }
#
# Reads Claude Code's status JSON on stdin. Every field access is defensive —
# the schema grows between versions and we degrade per-segment, never crash.
set -u

# VECTOR-PALETTE (keep in sync with palette/vector.json)
CYAN=$'\033[38;2;34;211;238m'
BLUE=$'\033[38;2;96;165;250m'
PINK=$'\033[38;2;232;121;160m'
AMBER=$'\033[38;2;240;180;41m'
CRIMSON=$'\033[38;2;255;93;115m'
FAINT=$'\033[38;2;90;114;144m'
DIM=$'\033[38;2;61;79;107m'
BOLD=$'\033[1m'
RESET=$'\033[0m'
SEP="${DIM} │ ${RESET}"

input=$(cat)

have_jq=0
command -v jq >/dev/null 2>&1 && have_jq=1

jqget() { # jqget <filter> — empty string on any failure
  [ "$have_jq" -eq 1 ] || { echo ""; return; }
  printf '%s' "$input" | jq -r "$1 // empty" 2>/dev/null
}

# ── model ────────────────────────────────────────────────────────
model=$(jqget '.model.display_name')
[ -z "$model" ] && model=$(jqget '.model.id')
[ -z "$model" ] && model="CLAUDE"
model=$(printf '%s' "$model" | tr '[:lower:]' '[:upper:]' | sed 's/^CLAUDE //')

out="${CYAN}${BOLD}◆ ${model}${RESET}"

# ── directory ────────────────────────────────────────────────────
dir=$(jqget '.workspace.current_dir')
[ -z "$dir" ] && dir=$(jqget '.cwd')
if [ -n "$dir" ]; then
  out="${out}${SEP}${BLUE}${BOLD}[ ${dir##*/} ]${RESET}"
fi

# ── git branch ───────────────────────────────────────────────────
if [ -n "$dir" ] && command -v git >/dev/null 2>&1; then
  branch=$(git -C "$dir" branch --show-current 2>/dev/null)
  if [ -n "$branch" ]; then
    out="${out}${SEP}${PINK} ${branch}${RESET}"
  fi
fi

# ── context meter (transcript-size heuristic) ────────────────────
transcript=$(jqget '.transcript_path')
if [ -n "$transcript" ] && [ -f "$transcript" ]; then
  bytes=$(wc -c < "$transcript" 2>/dev/null | tr -d ' ')
  if [ -n "$bytes" ] && [ "$bytes" -gt 0 ] 2>/dev/null; then
    # bytes -> ~tokens (/3.8 chars) -> % of ~160k usable window
    pct=$(( bytes * 100 / 38 / 16000 ))
    [ "$pct" -gt 100 ] && pct=100

    color=$PINK
    [ "$pct" -ge 80 ] && color=$AMBER
    [ "$pct" -ge 95 ] && color=$CRIMSON

    filled=$((pct / 10)); bar=""
    i=0
    while [ "$i" -lt 10 ]; do
      if [ "$i" -lt "$filled" ]; then bar="${bar}▓"; else bar="${bar}░"; fi
      i=$((i + 1))
    done
    out="${out}${SEP}${color}CTX ${pct}% ${bar}${RESET}"

    # Feed the tmux rail (vector-ctx.sh reads this file).
    mkdir -p "$HOME/.cache" 2>/dev/null
    printf '%s' "$pct" > "$HOME/.cache/claude-ctx" 2>/dev/null
  fi
fi

# ── session cost ─────────────────────────────────────────────────
cost=$(jqget '.cost.total_cost_usd')
if [ -n "$cost" ]; then
  cost=$(printf '%.2f' "$cost" 2>/dev/null || echo "$cost")
  out="${out}${SEP}${FAINT}\$${cost}${RESET}"
fi

printf '%s' "$out"
