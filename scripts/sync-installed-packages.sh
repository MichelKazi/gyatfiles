#!/bin/bash

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" &>/dev/null && pwd)"

command_exists() {
  command -v "$1" >/dev/null 2>&1
}

save_brew_packages() {
  if command_exists brew; then
    echo "Merging installed Homebrew packages into Brewfile..."
    # Snapshot first: a failed discovery must never damage the canonical file.
    brew bundle dump --file="$SYNC_TMP/installed.Brewfile" --force
    /usr/bin/ruby "$SCRIPT_DIR/merge-brewfile.rb" \
      "$SCRIPT_DIR/packages/Brewfile" "$SYNC_TMP/installed.Brewfile" \
      > "$SYNC_TMP/merged.Brewfile"
    if ! cmp -s "$SYNC_TMP/merged.Brewfile" "$SCRIPT_DIR/packages/Brewfile"; then
      mv "$SYNC_TMP/merged.Brewfile" "$SCRIPT_DIR/packages/Brewfile"
    fi
  else
    echo "Homebrew not found, skipping."
  fi
}

save_cargo_packages() {
  if command_exists cargo; then
    echo "Saving installed Cargo packages to cargo.txt..."
    cargo install --list | awk '/^[[:alnum:]]/ {print $1}' >"$SYNC_TMP/cargo.txt"
  else
    echo "Cargo not found, skipping."
  fi
}

save_yarn_packages() {
  if command_exists yarn; then
    echo "Saving installed Yarn packages to yarn.txt..."
    yarn global list --depth=0 | awk '/info "/ {print $2}' >"$SYNC_TMP/yarn.txt"
  else
    echo "Yarn not found, skipping."
  fi
}

save_npm_packages() {
  if command_exists npm; then
    echo "Saving installed npm packages to npm.txt..."
    npm list -g --depth=0 | grep '├──' | awk '{print $2}' >"$SYNC_TMP/npm.txt"
  else
    echo "npm not found, skipping."
  fi
}

save_gem_packages() {
  if command_exists gem; then
    echo "Saving installed Gem packages to gemfile..."
    gem list --local | awk '{print $1}' >"$SYNC_TMP/gemfile"
  else
    echo "Gem not found, skipping."
  fi
}

save_pip3_packages() {
  if command_exists pip3; then
    echo "Saving installed pip3 packages to pip.txt..."
    pip3 freeze >"$SYNC_TMP/pip.txt"
  else
    echo "pip3 not found, skipping."
  fi
}

case "${1:-}" in
  ""|--brew-only) ;;
  *) echo "Usage: $0 [--brew-only]" >&2; exit 2 ;;
esac

# Serialize both the weekly job and frequent Brew-only job. Keep temp files on
# the same filesystem as the destination so replacement is atomic.
LOCK_DIR="$SCRIPT_DIR/packages/.sync-lock"
if ! mkdir "$LOCK_DIR" 2>/dev/null; then
  echo "Package sync already running ($LOCK_DIR)." >&2
  exit 1
fi
SYNC_TMP=""
trap '[[ -z "$SYNC_TMP" ]] || rm -rf "$SYNC_TMP"; rmdir "$LOCK_DIR"' EXIT
trap 'exit 130' INT
trap 'exit 143' TERM
SYNC_TMP="$(mktemp -d "$SCRIPT_DIR/packages/.sync.XXXXXX")"

save_brew_packages
[[ "${1:-}" != --brew-only ]] || exit 0

# Generate each legacy snapshot separately, retaining the old file on failure.
save_snapshot() {
  local collector="$1" target="$2"
  if "$collector"; then
    if [[ -f "$SYNC_TMP/$target" ]]; then
      mv "$SYNC_TMP/$target" "$SCRIPT_DIR/packages/$target"
    fi
  else
    echo "Failed to generate $target; previous snapshot retained." >&2
    return 1
  fi
}
save_snapshot save_cargo_packages cargo.txt
save_snapshot save_yarn_packages yarn.txt
save_snapshot save_npm_packages npm.txt
save_snapshot save_gem_packages gemfile
save_snapshot save_pip3_packages pip.txt

echo "Package sync complete."
