#!/usr/bin/env bash
# Host-side Hyprland setup for the Steam Deck (SteamOS/Galileo OLED).
#
# Hyprland is the compositor: it runs on the HOST, not in a distrobox (a container
# can't own the host display/input). This is separate from install-arch.sh, which
# stows into the box.
#
# SteamOS rootfs is read-only. This machine already runs rwfus (an overlay on /usr,
# /etc/pacman.d, /var/cache/pacman), so pacman installs persist across SteamOS
# updates. We do NOT `steamos-readonly disable` — rwfus is the mechanism instead.
set -euo pipefail

DOTFILES_DIR="${DOTFILES_DIR:-$HOME/gyatfiles}"
WVKBD_VERSION="v0.16"
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

echo "=== Hyprland host setup (Steam Deck / SteamOS) ==="
[[ $DRY_RUN -eq 1 ]] && echo "MODE: dry run"

# --- Guard: this path assumes SteamOS + rwfus. ---
if ! command -v pacman >/dev/null 2>&1; then
  echo "Error: no pacman. This script targets SteamOS/Arch hosts only." >&2
  exit 1
fi
if ! mount | grep -q '/opt/rwfus'; then
  echo "Error: rwfus overlay not detected on this host." >&2
  echo "Without it, pacman installs land on the read-only rootfs and are wiped on" >&2
  echo "every SteamOS update. Install rwfus first: https://github.com/ValkyrieOfNight/Rwfus" >&2
  echo "(Then re-run this script.)" >&2
  exit 1
fi
echo "rwfus overlay detected — pacman installs will persist."

# --- Packages (all confirmed present in SteamOS extra-3.8). ---
PKGS=(
  hyprland xdg-desktop-portal-hyprland hyprpaper
  waybar swaync wob wofi
  grim slurp wl-clipboard brightnessctl libnotify qt6ct
  jq stow
  # wvkbd build deps:
  base-devel wayland wayland-protocols libxkbcommon pango cairo
)

echo "=== Installing packages ==="
# SteamOS ships an empty/uninitialised keyring often — make it usable first.
run sudo pacman-key --init
run sudo pacman-key --populate archlinux holo
run sudo pacman -Sy
run sudo pacman -S --needed --noconfirm "${PKGS[@]}"

# --- wvkbd is not in the SteamOS repos: build from source (hyprdose's approach). ---
if command -v wvkbd-mobintl >/dev/null 2>&1; then
  echo "wvkbd already installed, skipping build."
else
  echo "=== Building wvkbd $WVKBD_VERSION from source ==="
  if [[ $DRY_RUN -eq 1 ]]; then
    echo "[dry-run] git clone jjsullivan5196/wvkbd; checkout $WVKBD_VERSION; make PREFIX=/usr; sudo make install"
  else
    BUILD_DIR="$(mktemp -d)"
    git clone https://github.com/jjsullivan5196/wvkbd.git "$BUILD_DIR"
    git -C "$BUILD_DIR" checkout "$WVKBD_VERSION"
    make -C "$BUILD_DIR" PREFIX=/usr
    sudo make -C "$BUILD_DIR" PREFIX=/usr install
    rm -rf "$BUILD_DIR"
  fi
fi

# --- Stow the config (host ~/.config + ~/.local/bin). ---
echo "=== Stowing hyprland package ==="
run stow -d "$DOTFILES_DIR" -t "$HOME" hyprland

echo "=== Done ==="
cat <<'NOTE'
Next:
1. Log out to SDDM, pick the "Hyprland" session (the pacman hyprland package
   ships /usr/share/wayland-sessions/hyprland.desktop).
2. First boot: verify the panel is landscape and touch taps land correctly
   (monitor + touch transform,3 are set in hyprland.conf).
3. Controller: in Steam, apply a "Desktop Layout" that maps the pad to the
   ALT-based binds (hyprdose ships one in its community layout).
4. App launchers assume ghostty/obsidian/firefox/slack on PATH; install any you use.
NOTE
