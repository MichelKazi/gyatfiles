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
if ! command -v brew &>/dev/null; then
    for brew_path in /opt/homebrew/bin/brew /usr/local/bin/brew; do
        if [[ -x "$brew_path" ]]; then
            eval "$("$brew_path" shellenv)"
            break
        fi
    done
fi
if ! command -v brew &>/dev/null; then
    if [[ $DRY_RUN -eq 1 ]]; then
        echo "[dry-run] would install Homebrew"
    else
        echo "Installing Homebrew..."
        /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)" || exit 1
        if [[ -x /opt/homebrew/bin/brew ]]; then
            eval "$(/opt/homebrew/bin/brew shellenv)"
        else
            eval "$(/usr/local/bin/brew shellenv)"
        fi
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

# Homebrew core provides wtfutil. The legacy tap's formula fails tap validation.
export HOMEBREW_BUNDLE_TAP_SKIP="${HOMEBREW_BUNDLE_TAP_SKIP:+$HOMEBREW_BUNDLE_TAP_SKIP }wtfutil/wtfutil"
# Homebrew disabled this cask because it fails Gatekeeper validation.
export HOMEBREW_BUNDLE_CASK_SKIP="${HOMEBREW_BUNDLE_CASK_SKIP:+$HOMEBREW_BUNDLE_CASK_SKIP }ytmdesktop-youtube-music"

echo ""
echo "=== Packages ==="
if [[ $DRY_RUN -eq 1 ]]; then
    echo "[dry-run] would prepare Rust and uv before installing the bundle"
    if command -v brew &>/dev/null; then
        brew bundle check --file="$BREWFILE" --verbose || true
    fi
else
    export PATH="$HOME/.cargo/bin:$PATH"
    rustup_bin="$(brew --prefix rustup)/bin"
    if [[ -d "$rustup_bin" ]]; then
        export PATH="$PATH:$rustup_bin"
    fi
    if ! cargo --version &>/dev/null; then
        if brew install rustup; then
            export PATH="$rustup_bin:$PATH"
            rustup default stable || SETUP_FAILED=1
        else
            SETUP_FAILED=1
        fi
    fi
    command -v uv >/dev/null 2>&1 || brew install uv || SETUP_FAILED=1
    brew bundle install --file="$BREWFILE" || SETUP_FAILED=1
    # The shell aliases and Ghostty config expect these on a fresh Mac.
    command -v lsd >/dev/null 2>&1 || brew install lsd || SETUP_FAILED=1
    brew install --cask claude-code codex font-fira-code-nerd-font || SETUP_FAILED=1
fi

# --- Claude Code -------------------------------------------------------------
CLAUDE_DIR="$HOME/.claude"
CLAUDE_THEME="$DOTFILES_DIR/themes/vector/claude-code"
if [[ $DRY_RUN -eq 1 ]]; then
    echo "[dry-run] would set up the Vector status line for Claude Code"
elif mkdir -p "$CLAUDE_DIR"; then
    if [[ ! -e "$CLAUDE_DIR/vector-statusline.sh" && ! -L "$CLAUDE_DIR/vector-statusline.sh" ]]; then
        ln -s "$CLAUDE_THEME/vector-statusline.sh" "$CLAUDE_DIR/vector-statusline.sh" || SETUP_FAILED=1
    fi
    if [[ ! -e "$CLAUDE_DIR/settings.json" && ! -L "$CLAUDE_DIR/settings.json" ]]; then
        if settings="$(jq 'del(._comment)' "$CLAUDE_THEME/settings-snippet.json")"; then
            (set -o noclobber; printf '%s\n' "$settings" > "$CLAUDE_DIR/settings.json") || SETUP_FAILED=1
        else
            SETUP_FAILED=1
        fi
    fi
else
    SETUP_FAILED=1
fi

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
        if command -v stow &>/dev/null; then
            LC_ALL=C LANG=C stow -n -v -d "$DOTFILES_DIR" -t "$HOME" "$dir" 2>&1 | sed 's/^/    /' || SETUP_FAILED=1
        else
            echo "    would stow $dir after Homebrew installs Stow"
        fi
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

# --- Package inventory jobs --------------------------------------------------
for agent in "$DOTFILES_DIR"/scripts/launchd/*.plist; do
    target="$HOME/Library/LaunchAgents/$(basename "$agent")"
    if [[ $DRY_RUN -eq 1 ]]; then
        echo "[dry-run] would install and load launch agent: $target"
    else
        mkdir -p "$HOME/Library/LaunchAgents"
        launchctl bootout "gui/$(id -u)" "$target" 2>/dev/null || true
        cp "$agent" "$target" || { SETUP_FAILED=1; continue; }
        launchctl bootstrap "gui/$(id -u)" "$target" || SETUP_FAILED=1
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
