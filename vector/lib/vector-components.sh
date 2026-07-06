#!/usr/bin/env bash
# vector-components — the design grammar as shell functions.
# Source this from any script that renders Vector UI; stop hand-rolling
# segments. Two output contexts:
#   vx_tmux_*  emit tmux format strings (#[fg=..] style, click ranges)
#   vx_ansi_*  emit raw ANSI truecolor (statuslines, CLI output)
# Grammar reference: DESIGN.md. bash-3.2 clean.
# shellcheck disable=SC2034  # palette/glyph vars are the library's public API
#
# VECTOR-PALETTE (keep in sync with palette/vector.json)
VX_BG="#0a0e17";      VX_PANEL="#0d1a26";   VX_GRID="#1a2332"
VX_DIM="#3d4f6b";     VX_FAINT="#5a7290";   VX_TEXT="#c8d8ea"
VX_CYAN="#22d3ee";    VX_ICE="#7dd3fc";     VX_BLUE="#60a5fa"
VX_VIOLET="#b18aff";  VX_PINK="#e879a0";    VX_CRIMSON="#ff5d73"
VX_EMBER="#ff8f5e";   VX_AMBER="#f0b429";   VX_GREEN="#34d399"
VX_DIM_CYAN="#3091ac";   VX_DIM_BLUE="#4e7ab2";  VX_DIM_VIOLET="#776cb5"
VX_DIM_PINK="#926486";   VX_DIM_CRIMSON="#a05468"; VX_DIM_EMBER="#9e6f64"
VX_DIM_AMBER="#96824a";  VX_DIM_GREEN="#389182"; VX_DIM_ICE="#5d91b4"
VX_CRIMSON_BG="#2a1018"; VX_AMBER_BG="#241a08";  VX_GREEN_BG="#0c2018"
VX_BLUE_BG="#101f38";    VX_CYAN_BG="#0d1a26"

# Glyphs (palette/vector.json glyphs)
VX_POINTER="▸"; VX_MENU="▾"; VX_FLEET="◆"; VX_UP="●"
VX_OK="✓"; VX_DOWN="✗"; VX_PENDING="…"; VX_BUSY="✻"
VX_MFILL="▓"; VX_MEMPTY="░"; VX_DIVIDER="│"

vx_upper() { printf '%s' "$1" | tr '[:lower:]' '[:upper:]'; }

# ── tmux context ─────────────────────────────────────────────────────────
# vx_tmux_btn <label> <color> <fill_bg> <range> [active]
#   The Vector button: [ LABEL ], uppercase, bracketed, click-ranged.
#   active -> bold + fill + colored underline; else dim partner, no fill.
vx_tmux_btn() {
  local label range
  label=$(vx_upper "$1")
  range="$4"
  if [ "${5:-}" = "active" ]; then
    printf '#[range=user|%s]#[fg=%s,bg=%s,bold,underscore,us=%s] [ %s ] #[norange]#[default]' \
      "$range" "$2" "$3" "$2" "$label"
  else
    printf '#[range=user|%s]#[fg=%s,bg=default,bold] [ %s ] #[norange]#[default]' \
      "$range" "$2" "$label"
  fi
}

# vx_tmux_health <label> <state:up|down|pending> <range> [compact]
#   Indicator: VPN✓ / AWS✗ / VPN… or a bare colored ● in compact mode.
vx_tmux_health() {
  local color glyph
  case "$2" in
    up)      color="$VX_GREEN";   glyph="$VX_OK" ;;
    pending) color="$VX_AMBER";   glyph="$VX_PENDING" ;;
    *)       color="$VX_CRIMSON"; glyph="$VX_DOWN" ;;
  esac
  if [ "${4:-}" = "compact" ]; then
    printf '#[range=user|%s]#[fg=%s]%s#[norange]' "$3" "$color" "$VX_UP"
  else
    printf '#[range=user|%s]#[fg=%s,bold]%s%s#[norange]#[default] ' \
      "$3" "$color" "$(vx_upper "$1")" "$glyph"
  fi
}

# vx_tmux_meter <label> <pct>
#   10-cell escalating meter: pink -> amber >=80 -> crimson >=95.
vx_tmux_meter() {
  local pct color bar filled i
  pct="$2"; [ "$pct" -gt 100 ] && pct=100
  color="$VX_PINK"
  [ "$pct" -ge 80 ] && color="$VX_AMBER"
  [ "$pct" -ge 95 ] && color="$VX_CRIMSON"
  filled=$((pct / 10)); bar=""; i=0
  while [ "$i" -lt 10 ]; do
    if [ "$i" -lt "$filled" ]; then bar="$bar$VX_MFILL"; else bar="$bar$VX_MEMPTY"; fi
    i=$((i + 1))
  done
  printf '#[fg=%s]%s %s%% %s#[default] ' "$color" "$(vx_upper "$1")" "$pct" "$bar"
}

# vx_tmux_divider — thin │ in base.dim with breathing room
vx_tmux_divider() { printf '#[fg=%s] %s #[default]' "$VX_DIM" "$VX_DIVIDER"; }

# ── ANSI context ─────────────────────────────────────────────────────────
vx_hex2sgr() { # "#rrggbb" -> "38;2;r;g;b"
  local h=${1#\#}
  printf '38;2;%d;%d;%d' "0x${h:0:2}" "0x${h:2:2}" "0x${h:4:2}"
}

# vx_ansi <color_hex> [bold] — open a color; close with vx_ansi_reset
vx_ansi() {
  if [ "${2:-}" = "bold" ]; then
    printf '\033[1;%sm' "$(vx_hex2sgr "$1")"
  else
    printf '\033[%sm' "$(vx_hex2sgr "$1")"
  fi
}
vx_ansi_reset() { printf '\033[0m'; }

# vx_ansi_btn <label> <color_hex> — [ LABEL ] bracketed button, bold
vx_ansi_btn() {
  printf '%s[ %s ]%s' "$(vx_ansi "$2" bold)" "$(vx_upper "$1")" "$(vx_ansi_reset)"
}

# vx_ansi_health <label> <state:up|down|pending>
vx_ansi_health() {
  local color glyph
  case "$2" in
    up)      color="$VX_GREEN";   glyph="$VX_OK" ;;
    pending) color="$VX_AMBER";   glyph="$VX_PENDING" ;;
    *)       color="$VX_CRIMSON"; glyph="$VX_DOWN" ;;
  esac
  printf '%s%s%s%s' "$(vx_ansi "$color" bold)" "$(vx_upper "$1")" "$glyph" "$(vx_ansi_reset)"
}

# vx_ansi_meter <label> <pct> — same escalation as tmux variant
vx_ansi_meter() {
  local pct color bar filled i
  pct="$2"; [ "$pct" -gt 100 ] && pct=100
  color="$VX_PINK"
  [ "$pct" -ge 80 ] && color="$VX_AMBER"
  [ "$pct" -ge 95 ] && color="$VX_CRIMSON"
  filled=$((pct / 10)); bar=""; i=0
  while [ "$i" -lt 10 ]; do
    if [ "$i" -lt "$filled" ]; then bar="$bar$VX_MFILL"; else bar="$bar$VX_MEMPTY"; fi
    i=$((i + 1))
  done
  printf '%s%s %s%% %s%s' "$(vx_ansi "$color")" "$(vx_upper "$1")" "$pct" "$bar" "$(vx_ansi_reset)"
}

# vx_ansi_divider — thin │ in base.dim
vx_ansi_divider() { printf '%s %s %s' "$(vx_ansi "$VX_DIM")" "$VX_DIVIDER" "$(vx_ansi_reset)"; }

# ── frames ───────────────────────────────────────────────────────────────
# vx_popup <domain:sessions|uplink|remediate|neutral> <title> <w> <h> <cmd...>
#   Launch a tmux display-popup with the domain frame per DESIGN.md §5.
vx_popup() {
  local domain="$1" title="$2" w="$3" h="$4" color
  shift 4
  case "$domain" in
    sessions | remediate) color="$VX_CRIMSON" ;;
    uplink)               color="$VX_AMBER" ;;
    *)                    color="$VX_GRID" ;;
  esac
  tmux display-popup -E -w "$w" -h "$h" -b rounded \
    -S "fg=$color" -s "bg=$VX_BG" -T " VECTOR//$(vx_upper "$title") " "$@"
}
