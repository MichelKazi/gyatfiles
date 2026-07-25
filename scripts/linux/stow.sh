#!/usr/bin/env bash
# Phase: link dotfiles into $HOME with stow, backing up anything that would be clobbered,
# then install the tmux plugin manager.
#
# Carried over verbatim in behaviour from install-arch.sh: conflicting real files are
# moved to a timestamped dir under ~/.local/state/gyatfiles-backups/ rather than being
# overwritten, and files already symlinked to the right source are left alone.
set -euo pipefail
# shellcheck source=./lib.sh
source "$(dirname "${BASH_SOURCE[0]}")/lib.sh"

STOW_PACKAGES=(base linux)

[[ -d "$GYATFILES_DIR" ]] || { echo "Error: dotfiles directory not found: $GYATFILES_DIR"; exit 1; }

STOW_CONFLICTS=0
backup_stow_conflicts() {
  local backup_dir=""
  local package package_dir source relative target

  shopt -s dotglob globstar nullglob
  for package in "${STOW_PACKAGES[@]}"; do
    package_dir="$GYATFILES_DIR/$package"
    [[ -d "$package_dir" ]] || { echo "Error: Stow package missing: $package_dir"; exit 1; }
    for source in "$package_dir"/**; do
      [[ -f "$source" || -L "$source" ]] || continue
      relative="${source#"$package_dir"/}"
      target="$HOME/$relative"
      [[ -e "$target" || -L "$target" ]] || continue
      if [[ "$target" -ef "$source" ]]; then
        continue
      fi

      STOW_CONFLICTS=$((STOW_CONFLICTS + 1))
      if [[ $DRY_RUN -eq 1 ]]; then
        echo "[dry-run] would back up conflicting target: $target"
        continue
      fi

      if [[ -z "$backup_dir" ]]; then
        backup_dir="$HOME/.local/state/gyatfiles-backups/$(date +%Y%m%d-%H%M%S)"
      fi
      mkdir -p "$backup_dir/$(dirname "$relative")"
      mv "$target" "$backup_dir/$relative"
    done
  done
  shopt -u dotglob globstar nullglob

  [[ -z "$backup_dir" ]] || echo "Backed up conflicting targets to: $backup_dir"
}

say "Stowing shared config"
backup_stow_conflicts
if [[ $DRY_RUN -eq 1 ]]; then
  if [[ $STOW_CONFLICTS -gt 0 ]]; then
    echo "[dry-run] would stow ${STOW_PACKAGES[*]} after backing up conflicts"
  elif have stow; then
    stow -n -v -d "$GYATFILES_DIR" -t "$HOME" "${STOW_PACKAGES[@]}"
  else
    echo "[dry-run] would stow ${STOW_PACKAGES[*]} into $HOME after installing stow"
  fi
else
  require stow
  stow -d "$GYATFILES_DIR" -t "$HOME" "${STOW_PACKAGES[@]}"
fi

say "Tmux Plugin Manager"
if [[ ! -d "$HOME/.tmux/plugins/tpm" ]]; then
  run git clone https://github.com/tmux-plugins/tpm "$HOME/.tmux/plugins/tpm"
else
  echo "TPM already installed"
fi

say "stow phase done"
