#!/usr/bin/env bash
# Phase: CLI tooling via Homebrew. This is the whole terminal layer -- shell utilities,
# multiplexer, prompt, language version managers. It lives on the HOST, on /home, so it
# survives SteamOS updates and Bazzite image rebases alike, and it never grows the
# rwfus overlay.
set -euo pipefail
# shellcheck source=./lib.sh
source "$(dirname "${BASH_SOURCE[0]}")/lib.sh"

BREWFILE="$GYATFILES_DIR/scripts/linux/Brewfile"
PREFIX="$(brew_prefix)"

if in_container; then
  echo "Error: run the brew phase from the HOST. Homebrew is the host's CLI layer."
  exit 1
fi

[[ -f "$BREWFILE" ]] || { echo "Error: Brewfile not found: $BREWFILE"; exit 1; }

say "Homebrew"
if [[ -x "$PREFIX/bin/brew" ]]; then
  echo "Homebrew present: $("$PREFIX/bin/brew" --version | head -1)"
else
  case "$(detect_platform)" in
    ostree)
      # Bazzite/Bluefin/Aurora ship brew preinstalled; a missing binary means something
      # is wrong with the image, not that we should bootstrap over the top of it.
      echo "Error: expected Homebrew preinstalled on this image but $PREFIX/bin/brew is missing."
      exit 1
      ;;
    *)
      say "Installing Homebrew"
      run /bin/bash -c \
        "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
      ;;
  esac
fi

eval "$("$PREFIX/bin/brew" shellenv)"

# Golden rule 1: preview before mutating.
say "Brewfile"
if [[ $DRY_RUN -eq 1 ]]; then
  brew bundle check --file="$BREWFILE" --verbose || true
  echo "[dry-run] would run: brew bundle --file=$BREWFILE"
else
  brew bundle --file="$BREWFILE"
fi

say "brew phase done"
echo "Ensure this is on PATH in your shell rc:"
echo "  eval \"\$($PREFIX/bin/brew shellenv)\""
