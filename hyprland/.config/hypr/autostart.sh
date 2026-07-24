#!/usr/bin/env bash
# Hyprland autostart for the Deck. Guarded so a missing piece never breaks the
# rest of the chain. Launched once via exec-once in hyprland.conf.
source "$HOME/.config/hypr/deckrc" || true

have() { command -v "$1" >/dev/null 2>&1; }

# polkit auth agent (installed with plasma on SteamOS).
for p in /usr/lib/polkit-kde-authentication-agent-1 /usr/lib/polkit-gnome/polkit-gnome-authentication-agent-1; do
    [[ -x "$p" ]] && { "$p" &  break; }
done

# Noctalia: full Quickshell desktop shell — bar, notifications, launcher, OSD,
# touch widgets. Replaces waybar/swaync/wob (all one integrated shell). Already
# working under scroll; compositor-agnostic so it runs under Hyprland too.
have noctalia && noctalia &

# Steam + extest. On the Deck the desktop pointer IS Steam Input: it grabs the
# controller and emits mouse/keyboard, but via X11 XTEST which is dead under
# Wayland — so extest (32-bit libextest.so, built by install-hyprland-host.sh)
# bridges XTEST to a uinput virtual device Hyprland reads. Without both, the
# cursor freezes when Steam runs. Idempotent: only launch if not already up.
EXTEST="$HOME/.local/lib/libextest.so"
if [[ -f "$EXTEST" ]] && ! pgrep -x steam >/dev/null; then
    LD_PRELOAD="$EXTEST" /usr/bin/steam -silent &
fi

# GAP: wallpaper (hyprpaper) not shipped — Noctalia can set one, else solid black.
