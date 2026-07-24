#!/usr/bin/env bash
# Hyprland autostart for the Deck. Guarded so a missing piece never breaks the
# rest of the chain. Launched once via exec-once in hyprland.conf.
source "$HOME/.config/hypr/deckrc" || true

have() { command -v "$1" >/dev/null 2>&1; }

# wob OSD sink: deckctl writes 0-100 levels here, wob renders the bar.
if have wob; then
    rm -f "$DECK_WOBSOCK_PATH"; touch "$DECK_WOBSOCK_PATH"
    tail -f "$DECK_WOBSOCK_PATH" | wob &
fi

have waybar && waybar &
have swaync && swaync &

# polkit auth agent (installed with plasma on SteamOS).
for p in /usr/lib/polkit-kde-authentication-agent-1 /usr/lib/polkit-gnome/polkit-gnome-authentication-agent-1; do
    [[ -x "$p" ]] && { "$p" &  break; }
done

# Steam in desktop mode. -silent = start to tray. Runs as an Xwayland client;
# see the xwayland nofocus windowrule in hyprland.conf for the grab-bug guard.
# GAP: hyprdose LD_PRELOADs extest so Steam's global hotkeys work under Wayland.
# Skipped (needs building extest); add if you want Steam hotkeys captured globally.
have steam && steam -silent &

# GAP: no wallpaper (hyprpaper) shipped — desktop is solid black. Drop an image
# and add a hyprpaper.conf + `hyprpaper &` here if wanted.
