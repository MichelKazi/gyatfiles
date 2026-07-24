#!/usr/bin/env bash
# Host-side Hyprland setup for Bazzite / SteamOS desktop.
#
# IMPORTANT: Hyprland is the compositor — it runs on the HOST, not in a
# distrobox (a container can't own the host display/input). This script and the
# hyprland/ stow package are host-side. install-arch.sh stows into the box; this
# does not overlap with it.
#
# Bazzite (Fedora Atomic): layered via rpm-ostree, survives updates.
# SteamOS (Arch, read-only rootfs): pacman, WIPED on every SteamOS update.
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
  if [[ $DRY_RUN -eq 1 ]]; then printf '[dry-run] '; printf '%q ' "$@"; printf '\n'
  else "$@"; fi
}

echo "=== Hyprland host setup ==="
[[ $DRY_RUN -eq 1 ]] && echo "MODE: dry run"

if command -v rpm-ostree >/dev/null 2>&1; then
  echo "Detected rpm-ostree (Bazzite/Fedora Atomic)."
  echo "Layering Hyprland + deps. Reboot required after."
  run sudo rpm-ostree install --idempotent hyprland waybar wofi
  echo "NOTE: Bazzite may ship a Hyprland image variant — 'rpm-ostree rebase' to it is cleaner than layering. Check bazzite.gg docs."
elif command -v pacman >/dev/null 2>&1; then
  echo "Detected pacman (SteamOS/Arch)."
  echo "WARNING: SteamOS rootfs is read-only and WIPES layered packages on every system update."
  echo "You must disable readonly and re-run this after each SteamOS update."
  run sudo steamos-readonly disable || echo "(steamos-readonly not present — plain Arch, fine)"
  run sudo pacman -S --needed --noconfirm hyprland waybar wofi
else
  echo "Error: no rpm-ostree or pacman found. Unsupported host." >&2
  exit 1
fi

echo "=== Stowing hyprland config (host ~/.config/hypr) ==="
if command -v stow >/dev/null 2>&1; then
  run stow -d "$DOTFILES_DIR" -t "$HOME" hyprland
else
  echo "stow missing — install it, then: stow -d $DOTFILES_DIR -t $HOME hyprland"
fi

echo "=== Done ==="
echo "1. Edit ~/.config/hypr/hyprland.conf monitor lines after: hyprctl monitors"
echo "2. Log out, pick 'Hyprland' session at the display manager (SDDM/GDM)."
echo "3. App launchers assume: ghostty, obsidian, firefox, slack on PATH."
