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

# Steam is deliberately NOT autostarted. On the Deck the pointer is Steam Input's
# lizard mode; with no active Desktop Layout, a running Steam grabs the controller
# and FREEZES the Hyprland cursor (the Xwayland/Steam-Input grab bug). Launch Steam
# by hand once a Steam Input "Desktop Layout" is configured to drive the pointer.
# GAP: wallpaper (hyprpaper) not shipped — Noctalia can set one, else solid black.
