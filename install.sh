#!/bin/bash
# macOS dotfiles installer.
#
# Packages live in scripts/packages/Brewfile (the single source of truth,
# kept fresh by scripts/sync-installed-packages.sh). This script installs
# Homebrew, runs `brew bundle` against that Brewfile (formulae, casks, taps,
# cargo, npm, uv tools), initializes Rust, then stows configs.
#
# Dry run first to see what would change without touching anything:
#   ./install.sh --dry-run
set -uo pipefail

DOTFILES_DIR="${DOTFILES_DIR:-$HOME/gyatfiles}"
BREWFILE="$DOTFILES_DIR/scripts/packages/Brewfile"
DRY_RUN=0
SETUP_FAILED=0
BUNDLE_FAILED=0

for arg in "$@"; do
    case "$arg" in
        --dry-run|-n) DRY_RUN=1 ;;
        *) echo "Unknown arg: $arg (supported: --dry-run)"; exit 2 ;;
    esac
done

if [[ "$(uname -s)" != "Darwin" ]]; then
    echo "Error: install.sh supports macOS only; use install.linux.sh on Linux"
    exit 1
fi

echo "=== Dotfiles Setup (macOS) ==="
echo "Dotfiles directory: $DOTFILES_DIR"
[[ $DRY_RUN -eq 1 ]] && echo "MODE: dry run (no changes will be made)"
echo ""

if [[ ! -d "$DOTFILES_DIR" ]]; then
    echo "Error: dotfiles directory not found at $DOTFILES_DIR"
    echo "Clone your dotfiles repo there first:  git clone <repo> $DOTFILES_DIR"
    exit 1
fi

# Older layouts Stowed custom snippets as ~/.oh-my-zsh. That is not an Oh My
# Zsh installation and prevented both the framework and snippets from loading.
if [[ -L "$HOME/.oh-my-zsh" ]] && [[ "$(readlink "$HOME/.oh-my-zsh")" == *"gyatfiles/zsh/.oh-my-zsh" ]]; then
    if [[ $DRY_RUN -eq 1 ]]; then
        echo "[dry-run] would remove legacy ~/.oh-my-zsh symlink"
    else
        unlink "$HOME/.oh-my-zsh"
    fi
fi

# --- Homebrew ---------------------------------------------------------------
if ! command -v brew &> /dev/null; then
    if [[ $DRY_RUN -eq 1 ]]; then
        echo "[dry-run] would install Homebrew"
    else
        echo "Installing Homebrew..."
        /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
        [[ $(uname -m) == "arm64" ]] && eval "$(/opt/homebrew/bin/brew shellenv)"
    fi
else
    echo "Homebrew already installed"
fi

# --- Oh My Zsh ---------------------------------------------------------------
if [[ ! -d "$HOME/.oh-my-zsh" ]]; then
    if [[ $DRY_RUN -eq 1 ]]; then
        echo "[dry-run] would clone Oh My Zsh"
    else
        echo "Installing Oh My Zsh..."
        git clone --depth=1 https://github.com/ohmyzsh/ohmyzsh.git "$HOME/.oh-my-zsh"
    fi
else
    echo "Oh My Zsh already installed"
fi

# --- Packages (brew bundle) -------------------------------------------------
if [[ ! -f "$BREWFILE" ]]; then
    echo "Error: Brewfile not found at $BREWFILE"
    exit 1
fi

echo ""
echo "=== Packages ==="
if [[ $DRY_RUN -eq 1 ]]; then
    # `check` exits nonzero and lists everything missing; that's the point of a dry run.
    brew bundle check --file="$BREWFILE" --verbose || true
else
    # First pass: taps, formulae, casks, npm, uv. cargo entries may fail here
    # if the Rust toolchain isn't up yet; the second pass below fixes that.
    echo "Running brew bundle (pass 1)..."
    if ! brew bundle install --file="$BREWFILE"; then
        echo "brew bundle pass 1 failed; continuing to Rust before retry"
        BUNDLE_FAILED=1
    fi
fi

# --- Rust -------------------------------------------------------------------
echo ""
echo "=== Rust ==="
if [[ $DRY_RUN -eq 1 ]]; then
    if command -v cargo &> /dev/null; then
        echo "[dry-run] Rust already initialized"
    elif command -v rustup-init &> /dev/null; then
        echo "[dry-run] would run: rustup-init -y"
    else
        echo "[dry-run] Rust requires rustup from the Brewfile"
    fi
elif command -v cargo &> /dev/null; then
    echo "Rust already initialized"
elif command -v rustup-init &> /dev/null; then
    echo "Initializing Rust toolchain..."
    rustup-init -y
    export PATH="$HOME/.cargo/bin:$PATH"
else
    echo "Error: cargo and rustup-init are unavailable"
    SETUP_FAILED=1
fi

if [[ $DRY_RUN -eq 0 && $BUNDLE_FAILED -eq 1 ]] && command -v cargo &> /dev/null; then
    echo "Running brew bundle (pass 2)..."
    if brew bundle install --file="$BREWFILE"; then
        BUNDLE_FAILED=0
    else
        echo "brew bundle pass 2 failed"
    fi
fi

[[ $BUNDLE_FAILED -eq 1 ]] && SETUP_FAILED=1

# --- Stow -------------------------------------------------------------------
echo ""
echo "=== Stowing Dotfiles ==="

# Config directories with dotfiles to symlink. Add new ones here when you add
# a top-level config dir to the repo.
STOW_DIRS=(base macos)

cd "$DOTFILES_DIR" || exit 1
for dir in "${STOW_DIRS[@]}"; do
    if [[ ! -d "$DOTFILES_DIR/$dir" ]]; then
        echo "Error: Stow package missing: $DOTFILES_DIR/$dir"
        SETUP_FAILED=1
        continue
    fi
    if [[ $DRY_RUN -eq 1 ]]; then
        echo "[dry-run] stow $dir:"
        LC_ALL=C LANG=C stow -n -v -d "$DOTFILES_DIR" -t "$HOME" "$dir" 2>&1 | sed 's/^/    /'
    elif LC_ALL=C LANG=C stow -n -d "$DOTFILES_DIR" -t "$HOME" "$dir" 2>&1 | grep -q "existing target"; then
        echo "Conflict: $dir (run 'stow --adopt $dir' to adopt existing files)"
        SETUP_FAILED=1
    else
        echo "Stowing: $dir"
        if ! LC_ALL=C LANG=C stow -d "$DOTFILES_DIR" -t "$HOME" "$dir"; then
            echo "Failed to stow $dir"
            SETUP_FAILED=1
        fi
    fi
done

echo ""
if [[ $SETUP_FAILED -eq 0 ]]; then
    echo "=== Setup Complete ==="
else
    echo "=== Setup Incomplete ==="
    echo "One or more setup steps failed; review the errors above."
fi
[[ $DRY_RUN -eq 1 ]] && echo "(dry run — nothing was changed)"
echo "Restart your terminal to apply all changes."
exit "$SETUP_FAILED"
