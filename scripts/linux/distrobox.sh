#!/usr/bin/env bash
# Phase: provision the `arch-base` distrobox as a DEVELOPMENT environment only.
#
#   HOST -> terminal layer: shell, prompt, multiplexer, file/search CLI (brew phase).
#   BOX  -> toolchains, headers, build deps. Nothing a terminal session needs to start.
#
# Why tmux is not here: $HOME and /tmp are shared between host and box, so two tmux
# servers can reach the same socket dir. Host tmux 3.5a and Arch-rolling tmux 3.7b refuse
# to talk (protocol mismatch), which is what forced the ~/bin/tmux forwarding shim. One
# tmux, host-side, from brew, removes the shim, the TMUX_TMPDIR split, and the recursion
# guard. From inside this box that same binary is reachable via brew_prefix() in lib.sh.
set -euo pipefail
# shellcheck source=./lib.sh
source "$(dirname "${BASH_SOURCE[0]}")/lib.sh"

BOX="${BOX:-arch-base}"
IMAGE="${IMAGE:-docker.io/library/archlinux:latest}"

if in_container; then
  echo "Error: run the distrobox phase from the HOST, not from inside a box."
  echo "  distrobox-host-exec $GYATFILES_DIR/install.linux.sh --only distrobox"
  exit 1
fi

require distrobox

# ─── toolchains and build deps ───────────────────────────────────────────────
DEV_PACKAGES=(
  base base-devel cmake git lua luarocks nodejs npm python python-pip sudo
  glibc-locales man-db man-pages diffutils unzip zip pigz rsync openssh time bc words
)

# Build deps for the Selene / Moonlight / streaming work that lives in this box.
MEDIA_PACKAGES=(
  dav1d ffmpeg libplacebo libpulse libva libvdpau mesa opus
  qt6-base qt6-declarative qt6-multimedia qt6-svg
  sdl2-compat sdl2_ttf vulkan-headers vulkan-intel vulkan-radeon vte-common
)

# Network / diagnostic tools used from inside the box during streaming debugging.
NET_PACKAGES=(inetutils lsof mtr tcpdump traceroute nss-mdns xorg-xauth)

# ─── NOT installed here, and where each went instead ─────────────────────────
# Per gyatfiles CLAUDE.md rule 5: name the gap, never silently drop.
#
#   tmux                        -> HOST via brew. See the header. Do not re-add it here.
#   zsh + plugins, oh-my-zsh,
#   starship                    -> HOST. The login shell belongs to the machine, not to
#                                  a container you might not have entered.
#   bat fd fzf jq less lsd
#   ripgrep tree wget zoxide
#   thefuck stow neovim         -> HOST via scripts/linux/Brewfile. You want these in a
#                                  rescue shell and over SSH, where the box may be down.
#   ttf-jetbrains-mono-nerd     -> HOST. Fonts are rendered by the host compositor; a
#                                  font inside the box is invisible to it.
#   bash-completion             -> HOST, follows the shell.
#   yay                         -> dropped. The host has paru; a pure dev box has no AUR
#                                  needs once the terminal layer is gone. Re-add only if
#                                  a dev dependency turns out to be AUR-only.

say "distrobox devbox setup"
echo "Box:   $BOX"
echo "Image: $IMAGE"

if distrobox list 2>/dev/null | awk -F'|' '{gsub(/ /,"",$2); print $2}' | grep -qx "$BOX"; then
  echo "Box '$BOX' already exists; provisioning in place."
else
  echo "Creating box '$BOX'..."
  run distrobox create --name "$BOX" --image "$IMAGE" --yes
fi

ALL_PACKAGES=("${DEV_PACKAGES[@]}" "${MEDIA_PACKAGES[@]}" "${NET_PACKAGES[@]}")

say "Packages (${#ALL_PACKAGES[@]})"
if [[ $DRY_RUN -eq 1 ]]; then
  run distrobox enter "$BOX" -- sudo pacman -Sp --print-format '%n %v' "${ALL_PACKAGES[@]}"
else
  distrobox enter "$BOX" -- sudo pacman -Syu --needed --noconfirm "${ALL_PACKAGES[@]}"
fi

# ─── remove the terminal layer if an older install run put it in the box ─────
STRAY=(tmux zsh zsh-autosuggestions zsh-syntax-highlighting starship bat fd fzf lsd
       ripgrep tree zoxide thefuck stow neovim ttf-jetbrains-mono-nerd bash-completion)

say "Terminal-layer packages to remove from the box"
if [[ $DRY_RUN -eq 1 ]]; then
  echo "[dry-run] would check for and remove, if present: ${STRAY[*]}"
else
  mapfile -t present < <(distrobox enter "$BOX" -- pacman -Qq "${STRAY[@]}" 2>/dev/null || true)
  if [[ ${#present[@]} -gt 0 ]]; then
    echo "Removing: ${present[*]}"
    distrobox enter "$BOX" -- sudo pacman -Rns --noconfirm "${present[@]}"
  else
    echo "None present; box is already terminal-layer clean."
  fi
fi

say "distrobox phase done"
