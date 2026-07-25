#!/usr/bin/env bash
# Phase: AI coding CLIs + the shared skills/config repo.
#
# Install routes, chosen from what brew actually offers on Linux (checked, not assumed):
#   opencode     -> brew. It is a real formula with an x86_64_linux bottle, so it belongs
#                   in the CLI layer like everything else and gets brew's update path.
#                   Deliberately NOT duplicated into scripts/linux/Brewfile -- one source
#                   of truth, and it lives here with the rest of the AI stack.
#   claude-code  -> native installer. Homebrew has a claude-code CASK, which is macOS-only;
#                   there is no formula, so brew cannot serve it on Linux.
#   codex        -> npm. No formula either.
#
# Usage:
#   ./ai-tools.sh [--skills-repo URL] [--skills-dir PATH]
#   SKILLS_REPO=... SKILLS_DIR=... ./ai-tools.sh
# With no repo given and a TTY attached, it prompts. Non-interactive or --dry-run uses
# the default and never blocks.
set -euo pipefail
# shellcheck source=./lib.sh
source "$(dirname "${BASH_SOURCE[0]}")/lib.sh"

SKILLS_REPO="${SKILLS_REPO:-}"
SKILLS_DIR="${SKILLS_DIR:-$HOME/dotfiles/ai}"
DEFAULT_REPO="git@github.com:MichelKazi/ai-dotfiles.git"

while [[ $# -gt 0 ]]; do
  case "$1" in
    --skills-repo) shift; SKILLS_REPO="$1" ;;
    --skills-dir)  shift; SKILLS_DIR="$1" ;;
    *) echo "Unknown arg: $1 (supported: --skills-repo URL, --skills-dir PATH)"; exit 2 ;;
  esac
  shift
done

if in_container; then
  echo "Error: run the ai-tools phase from the HOST. These CLIs drive the host shell and"
  echo "their config lives in \$HOME, which the box only shares -- it does not own."
  exit 1
fi

# ─── AI CLIs ─────────────────────────────────────────────────────────────────
PREFIX="$(brew_prefix)"

say "opencode (via brew)"
if [[ -x "$PREFIX/bin/brew" ]]; then
  eval "$("$PREFIX/bin/brew" shellenv)"
  if brew list --formula opencode >/dev/null 2>&1; then
    echo "opencode already installed: $(opencode --version 2>/dev/null || echo present)"
  else
    run brew install opencode
  fi
else
  echo "Warning: brew not found at $PREFIX. Run the brew phase first; skipping opencode."
fi

say "claude code"
if have claude; then
  echo "claude already installed: $(claude --version 2>/dev/null || echo present)"
else
  run bash -c 'curl -fsSL https://claude.ai/install.sh | bash'
fi

say "codex"
if have codex; then
  echo "codex already installed: $(codex --version 2>/dev/null || echo present)"
elif have npm; then
  run npm install -g @openai/codex
elif [[ $DRY_RUN -eq 1 ]]; then
  # npm arrives with brew's `node`, which the brew phase installs before this one. A
  # preview must not fail just because that has not happened yet.
  echo "[dry-run] npm not on PATH yet; the brew phase installs node (which provides npm)."
  echo "[dry-run] would run: npm install -g @openai/codex"
else
  echo "Error: npm not found. Run the brew phase first -- node provides npm."
  exit 1
fi

# ─── skills / shared config repo ─────────────────────────────────────────────
say "skills repo"

if [[ -z "$SKILLS_REPO" ]]; then
  if [[ -d "$SKILLS_DIR/.git" ]]; then
    # Already cloned: keep whatever remote it actually has rather than re-pointing it.
    SKILLS_REPO="$(git -C "$SKILLS_DIR" remote get-url origin 2>/dev/null || echo "$DEFAULT_REPO")"
    echo "Existing clone found; using its remote: $SKILLS_REPO"
  elif [[ -t 0 && $DRY_RUN -eq 0 ]]; then
    read -r -p "GitHub repo holding your skills/config [$DEFAULT_REPO]: " SKILLS_REPO
    SKILLS_REPO="${SKILLS_REPO:-$DEFAULT_REPO}"
  else
    SKILLS_REPO="$DEFAULT_REPO"
    echo "Non-interactive; using default: $SKILLS_REPO"
  fi
fi

echo "Repo: $SKILLS_REPO"
echo "Dir:  $SKILLS_DIR"

if [[ -d "$SKILLS_DIR/.git" ]]; then
  run git -C "$SKILLS_DIR" pull --ff-only
else
  run mkdir -p "$(dirname "$SKILLS_DIR")"
  run git clone "$SKILLS_REPO" "$SKILLS_DIR"
fi

# ─── link the repo into the places each tool reads ───────────────────────────
# Left side = where the tool looks; right side = path inside the repo.
# Derived from the links already present on this machine, not invented.
LINKS=(
  "$HOME/.claude/skills|claude/skills"
  "$HOME/.config/opencode/opencode.json|opencode/opencode.json"
  "$HOME/.config/opencode/oh-my-openagent.json|opencode/oh-my-openagent.json"
)

say "linking config"
BACKUP_DIR="$HOME/.local/state/gyatfiles-backups/ai-$(date +%Y%m%d-%H%M%S)"
for entry in "${LINKS[@]}"; do
  target="${entry%%|*}"
  rel="${entry#*|}"
  source="$SKILLS_DIR/$rel"

  if [[ ! -e "$source" ]]; then
    # Rule 5: name the gap, do not silently skip.
    echo "  SKIP  $target -- not in repo: $rel"
    continue
  fi

  if [[ -L "$target" && "$(readlink -f "$target")" == "$(readlink -f "$source")" ]]; then
    echo "  ok    $target"
    continue
  fi

  if [[ -e "$target" || -L "$target" ]]; then
    # Never clobber: a real file here is config the user may not have committed.
    if [[ $DRY_RUN -eq 1 ]]; then
      echo "  [dry-run] would back up $target then link -> $source"
      continue
    fi
    mkdir -p "$BACKUP_DIR/$(dirname "${target#"$HOME"/}")"
    mv "$target" "$BACKUP_DIR/${target#"$HOME"/}"
    echo "  backed up $target"
  fi

  run mkdir -p "$(dirname "$target")"
  run ln -s "$source" "$target"
  echo "  link  $target -> $source"
done

[[ -d "$BACKUP_DIR" ]] && echo "Backups: $BACKUP_DIR"

say "ai-tools phase done"
cat <<'EOF'
Notes:
  - `codex` here installs from npm. The copy currently on this Deck is a self-managed
    standalone (~/.codex/packages/standalone/, 0.145.0-x86_64-unknown-linux-musl) whose
    installer is not recorded on disk -- if you know it, swap the npm line for it.
  - The repo also carries ssh/config.d, which nothing links today. If you want it,
    add an `Include ~/.ssh/config.d/*` line to ~/.ssh/config and extend LINKS above.
EOF
