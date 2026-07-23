#!/usr/bin/env bash
# Arch Linux installer for shared gyatfiles base plus Linux-safe overrides.
set -euo pipefail

DOTFILES_DIR="${DOTFILES_DIR:-$HOME/gyatfiles}"
DRY_RUN=0

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
      yay -Sp "$package"
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
if [[ $DRY_RUN -eq 1 ]]; then
  stow -n -v -d "$DOTFILES_DIR" -t "$HOME" base
else
  stow -d "$DOTFILES_DIR" -t "$HOME" base
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
