#!/usr/bin/env bash
# Phase: host distro packages.
#
# Deliberately tiny. Brew owns the CLI layer, so the only things that belong here are
# the ones brew structurally cannot provide on Linux:
#
#   zsh    -- a login shell must be a real system shell listed in /etc/shells, or chsh
#             refuses it. A brew zsh cannot be your login shell.
#   fonts  -- rendered by the host compositor, which does not look inside brew's prefix
#             (and font casks are macOS-only anyway).
#
# Everything else stays out on purpose: on SteamOS every host package is a file in the
# rwfus overlay permanently shadowing the base image underneath, and on Bazzite host
# packages belong in the bootc image, not in an imperative layer.
set -euo pipefail
# shellcheck source=./lib.sh
source "$(dirname "${BASH_SOURCE[0]}")/lib.sh"

if in_container; then
  echo "Error: run the packages phase from the HOST."
  exit 1
fi

PLATFORM="$(detect_platform)"
say "Host packages ($PLATFORM)"

ARCH_PACKAGES=(zsh ttf-jetbrains-mono-nerd)

case "$PLATFORM" in
  steamos|arch)
    require pacman
    require sudo
    if [[ $DRY_RUN -eq 1 ]]; then
      pacman -Sp --print-format '%n %v' "${ARCH_PACKAGES[@]}"
    else
      # NEVER -Syu here. On SteamOS with rwfus, a full upgrade resolves against repos
      # that move while the base image does not, which upstream documents as leaving a
      # partially updated system prone to boot-loops. Targeted -S only.
      sudo pacman -S --needed --noconfirm "${ARCH_PACKAGES[@]}"
    fi
    ;;
  ostree)
    echo "Image-based host: nothing to install imperatively."
    echo "zsh and the Nerd Font belong in the bootc image. Add to the Containerfile:"
    echo "    RUN dnf5 install -y zsh jetbrains-mono-fonts"
    echo "then rebuild and 'bootc switch'. Skipping."
    ;;
  *)
    echo "Unknown platform; skipping host packages."
    echo "Install manually if needed: ${ARCH_PACKAGES[*]}"
    ;;
esac

say "packages phase done"
