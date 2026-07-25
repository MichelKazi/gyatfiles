#!/usr/bin/env bash
# Shared helpers for install.linux.sh and its phase scripts. Source, do not execute.

GYATFILES_DIR="${GYATFILES_DIR:-${DOTFILES_DIR:-$HOME/gyatfiles}}"
DRY_RUN="${DRY_RUN:-0}"

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

have() { command -v "$1" >/dev/null 2>&1; }

say() { printf '\n=== %s ===\n' "$*"; }

in_container() { [[ -f /run/.containerenv ]] || [[ -n "${CONTAINER_ID:-}" ]]; }

# steamos | arch | ostree | unknown
# ostree covers Bazzite/Bluefin/Aurora: the host filesystem is image-owned, so no phase
# may install host packages there -- they belong in the bootc image instead.
detect_platform() {
  [[ -f /run/ostree-booted ]] && { echo ostree; return; }
  local id id_like
  id="$( . /etc/os-release 2>/dev/null && echo "${ID:-}" )"
  id_like="$( . /etc/os-release 2>/dev/null && echo "${ID_LIKE:-}" )"
  case "$id" in
    steamos) echo steamos ;;
    arch)    echo arch ;;
    *)       if [[ "$id_like" == *arch* ]]; then echo arch; else echo unknown; fi ;;
  esac
}

# The brew prefix differs by side of the container boundary: distrobox mounts the host's
# whole /home at /run/host/home, but does NOT mount /home/linuxbrew into $HOME's tree.
brew_prefix() {
  if in_container; then
    echo /run/host/home/linuxbrew/.linuxbrew
  else
    echo /home/linuxbrew/.linuxbrew
  fi
}
