#!/bin/bash
#
# bootstrap.sh — one-shot fresh-machine setup for gyatfiles.
#
# Bare macOS -> fully provisioned, in a single command:
#   /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/MichelKazi/gyatfiles/main/bootstrap.sh)"
#
# Steps: Xcode Command Line Tools (git + curl) -> clone gyatfiles -> exec install.sh
# (install.sh does Homebrew + formulae + casks + stow). install.sh is the source
# of truth for what gets installed; this only handles the pre-clone bootstrap.
set -e

REPO_URL="${REPO_URL:-https://github.com/MichelKazi/gyatfiles.git}"
DOTFILES_DIR="${DOTFILES_DIR:-$HOME/gyatfiles}"

echo "=== gyatfiles bootstrap ==="

# 1. Xcode Command Line Tools — provides git + curl on a bare Mac.
if ! xcode-select -p &>/dev/null; then
    echo "Installing Xcode Command Line Tools (accept the GUI prompt)..."
    xcode-select --install || true
    # Wait for the install to finish (the CLT installer runs in its own GUI process).
    until xcode-select -p &>/dev/null; do
        echo "  waiting for Command Line Tools install to complete..."
        sleep 15
    done
else
    echo "Xcode Command Line Tools already installed"
fi

# 2. Clone (or update) the dotfiles repo.
if [[ -d "$DOTFILES_DIR/.git" ]]; then
    echo "Repo present at $DOTFILES_DIR — pulling latest"
    git -C "$DOTFILES_DIR" pull --ff-only || echo "Pull skipped (dirty or diverged), continuing with existing checkout"
else
    echo "Cloning $REPO_URL -> $DOTFILES_DIR"
    git clone "$REPO_URL" "$DOTFILES_DIR"
fi

# 3. Hand off to the provisioning script.
echo "=== Handing off to install.sh ==="
cd "$DOTFILES_DIR"
exec ./install.sh
