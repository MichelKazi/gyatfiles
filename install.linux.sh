#!/usr/bin/env bash
# gyatfiles Linux installer. Replaces install-arch.sh.
#
# Four phases, each runnable alone. The split reflects where a thing actually has to
# live, which is the lesson from the SteamOS kernel/module wedge: put each piece in the
# layer that owns its lifetime, and stop papering over the seams.
#
#   brew       CLI tooling on the host, on /home. Survives SteamOS updates and Bazzite
#              image rebases, and never grows the rwfus overlay.
#   packages   The two things brew structurally cannot do on Linux: the login shell
#              (chsh needs /etc/shells) and fonts (the compositor cannot see brew's prefix).
#   distrobox  arch-base, provisioned as a pure development environment.
#   stow       Link dotfiles into $HOME, backing up conflicts, then TPM.
#
# Usage:
#   ./install.linux.sh [--dry-run] [--only PHASE]... [--skip PHASE]...
#
# Golden rule 1: run --dry-run first and read the output.
set -euo pipefail

GYATFILES_DIR="${GYATFILES_DIR:-${DOTFILES_DIR:-$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)}}"
export GYATFILES_DIR
PHASE_DIR="$GYATFILES_DIR/scripts/linux"

ALL_PHASES=(brew packages distrobox ai-tools stow)
ONLY=()
SKIP=()
DRY_RUN=0

while [[ $# -gt 0 ]]; do
  case "$1" in
    --dry-run|-n) DRY_RUN=1 ;;
    --only) shift; ONLY+=("$1") ;;
    --skip) shift; SKIP+=("$1") ;;
    -h|--help)
      sed -n '2,20p' "${BASH_SOURCE[0]}" | sed 's/^# \{0,1\}//'
      exit 0 ;;
    *) echo "Unknown arg: $1 (supported: --dry-run, --only PHASE, --skip PHASE)"; exit 2 ;;
  esac
  shift
done
export DRY_RUN

in_list() { local n="$1"; shift; local x; for x in "$@"; do [[ "$x" == "$n" ]] && return 0; done; return 1; }

# Validate phase names up front rather than silently running nothing.
for p in "${ONLY[@]}" "${SKIP[@]}"; do
  in_list "$p" "${ALL_PHASES[@]}" || { echo "Unknown phase: $p (valid: ${ALL_PHASES[*]})"; exit 2; }
done

if [[ -f /run/.containerenv ]] || [[ -n "${CONTAINER_ID:-}" ]]; then
  echo "Error: run this from the HOST. \$HOME is shared, so it is easy to land here from"
  echo "inside arch-base by accident."
  echo "  distrobox-host-exec $GYATFILES_DIR/install.linux.sh $*"
  exit 1
fi

echo "=== gyatfiles Linux install ==="
echo "Dotfiles: $GYATFILES_DIR"
[[ $DRY_RUN -eq 1 ]] && echo "MODE: dry run (no changes will be made)"

FAILED=()
for phase in "${ALL_PHASES[@]}"; do
  if [[ ${#ONLY[@]} -gt 0 ]] && ! in_list "$phase" "${ONLY[@]}"; then continue; fi
  if in_list "$phase" "${SKIP[@]}"; then echo "--- skipping phase: $phase"; continue; fi

  script="$PHASE_DIR/$phase.sh"
  [[ -f "$script" ]] || { echo "Error: phase script missing: $script"; exit 1; }

  # A failed phase must not silently abort the rest; report at the end instead.
  if bash "$script"; then :; else
    echo "!!! phase '$phase' failed (exit $?)"
    FAILED+=("$phase")
  fi
done

echo
if [[ ${#FAILED[@]} -gt 0 ]]; then
  echo "=== Completed with failures: ${FAILED[*]} ==="
  exit 1
fi

echo "=== Setup complete ==="
cat <<'EOF'

If you are migrating off the old single-tmux-in-a-box layout, do this in order --
inverted, you end up with no tmux at all:

  1. Confirm brew's tmux is on the host:      tmux -V
  2. Finish or kill any tmux sessions still running inside arch-base.
  3. Re-run:                                  ./install.linux.sh --only distrobox
  4. Retire the forwarding shim:              rm ~/bin/tmux
     and remove the TMUX_TMPDIR line from ~/.bashrc, plus the container-only tmux
     auto-start in base/.config/gyatfiles/zsh/custom/init-arch.zsh.
EOF
