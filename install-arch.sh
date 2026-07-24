#!/usr/bin/env bash
# Arch Linux installer for shared gyatfiles base plus Linux-safe overrides.
set -euo pipefail

DOTFILES_DIR="${DOTFILES_DIR:-$HOME/gyatfiles}"
DRY_RUN=0
STOW_PACKAGES=(base linux)

for arg in "$@"; do
  case "$arg" in
    --dry-run|-n) DRY_RUN=1 ;;
    *) echo "Unknown arg: $arg (supported: --dry-run)"; exit 2 ;;
  esac
done

run() {
  if [[ $DRY_RUN -eq 1 ]]; then
    printf '[dry-run] '; printf '%q ' "$@"; printf '\n'
  else
    "$@"
  fi
}

require() {
  command -v "$1" >/dev/null 2>&1 || { echo "Error: required command missing: $1"; exit 1; }
}

STOW_CONFLICTS=0
backup_stow_conflicts() {
  local backup_dir=""
  local package package_dir source relative target

  shopt -s dotglob globstar nullglob
  for package in "${STOW_PACKAGES[@]}"; do
    package_dir="$DOTFILES_DIR/$package"
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

[[ -d "$DOTFILES_DIR" ]] || { echo "Error: dotfiles directory not found: $DOTFILES_DIR"; exit 1; }
require pacman
require sudo

PACMAN_PACKAGES=(
  base-devel bat cmake curl fd fzf git jq lsd lua luarocks neovim nodejs npm
  python python-pip ripgrep starship stow tmux tree ttf-jetbrains-mono-nerd
  thefuck unzip wget zoxide zsh zsh-autosuggestions zsh-syntax-highlighting
)
AUR_PACKAGES=(oh-my-zsh-git)

echo "=== gyatfiles setup (Arch Linux) ==="
echo "Dotfiles directory: $DOTFILES_DIR"
[[ $DRY_RUN -eq 1 ]] && echo "MODE: dry run (no changes will be made)"

echo "=== Official packages ==="
if [[ $DRY_RUN -eq 1 ]]; then
  pacman -Sp --print-format '%n %v' "${PACMAN_PACKAGES[@]}"
else
  sudo pacman -S --needed --noconfirm "${PACMAN_PACKAGES[@]}"
fi

YAY_BUILD_DIR=""
cleanup() {
  [[ -z "$YAY_BUILD_DIR" ]] || rm -rf "$YAY_BUILD_DIR"
}
trap cleanup EXIT

install_yay() {
  if command -v yay >/dev/null 2>&1; then
    echo "yay already installed"
    return
  fi
  if [[ $DRY_RUN -eq 1 ]]; then
    echo "[dry-run] would build yay from https://aur.archlinux.org/yay.git"
    return
  fi
  YAY_BUILD_DIR="$(mktemp -d)"
  git clone https://aur.archlinux.org/yay.git "$YAY_BUILD_DIR/yay"
  (cd "$YAY_BUILD_DIR/yay" && makepkg -si --noconfirm)
  rm -rf "$YAY_BUILD_DIR"
  YAY_BUILD_DIR=""
}

echo "=== AUR packages ==="
install_yay
for package in "${AUR_PACKAGES[@]}"; do
  if [[ $DRY_RUN -eq 1 ]]; then
    if command -v yay >/dev/null 2>&1; then
      if yay -Q "$package" >/dev/null 2>&1; then
        echo "Already installed: $package"
      else
        yay -Si "$package" >/dev/null
        echo "[dry-run] would install AUR package: $package"
      fi
    else
      echo "[dry-run] AUR package to resolve after yay bootstrap: $package"
    fi
  elif yay -Q "$package" >/dev/null 2>&1; then
    echo "Already installed: $package"
  else
    yay -S --needed --noconfirm "$package"
  fi
done

echo "=== Stowing shared config ==="
backup_stow_conflicts
if [[ $DRY_RUN -eq 1 ]]; then
  if [[ $STOW_CONFLICTS -gt 0 ]]; then
    echo "[dry-run] would stow ${STOW_PACKAGES[*]} after backing up conflicts"
  elif command -v stow >/dev/null 2>&1; then
    stow -n -v -d "$DOTFILES_DIR" -t "$HOME" "${STOW_PACKAGES[@]}"
  else
    echo "[dry-run] would stow ${STOW_PACKAGES[*]} into $HOME after installing stow"
  fi
else
  require stow
  stow -d "$DOTFILES_DIR" -t "$HOME" "${STOW_PACKAGES[@]}"
fi

echo "=== Tmux Plugin Manager ==="
if [[ ! -d "$HOME/.tmux/plugins/tpm" ]]; then
  run git clone https://github.com/tmux-plugins/tpm "$HOME/.tmux/plugins/tpm"
else
  echo "TPM already installed"
fi

echo "=== Setup complete ==="
echo "Run: exec zsh"
echo "Optional distrobox exports:"
for binary in nvim tmux zsh starship; do
  if binary_path="$(command -v "$binary" 2>/dev/null)"; then
    echo "  distrobox-export --bin $binary_path"
  fi
done
