#!/bin/bash
# Arch Linux / Steam Deck dotfiles installer
# Installs zsh, neovim, and tmux configurations
set -e

DOTFILES_DIR="${DOTFILES_DIR:-$HOME/gyatfiles}"

echo "=== Arch Linux Dotfiles Setup (zsh, nvim, tmux) ==="
echo "Dotfiles directory: $DOTFILES_DIR"
echo ""

# Check if we're on Arch-based system
if ! command -v pacman &> /dev/null; then
    echo "Error: This script is for Arch Linux-based systems only"
    exit 1
fi

# Install yay if not present (AUR helper)
install_yay() {
    if ! command -v yay &> /dev/null; then
        echo "Installing yay (AUR helper)..."
        sudo pacman -S --needed --noconfirm git base-devel

        local temp_dir=$(mktemp -d)
        git clone https://aur.archlinux.org/yay.git "$temp_dir/yay"
        cd "$temp_dir/yay"
        makepkg -si --noconfirm
        cd -
        rm -rf "$temp_dir"
    else
        echo "yay already installed"
    fi
}

echo "=== Installing yay ==="
install_yay

echo ""
echo "=== Installing Packages ==="

# Core packages from official repos
PACMAN_PACKAGES=(
    # Shell
    zsh

    # Editor
    neovim

    # Terminal multiplexer
    tmux

    # Essential tools
    git
    stow
    curl
    wget
    unzip

    # CLI utilities used in configs
    fzf
    ripgrep
    fd
    bat
    zoxide
    lsd
    jq
    tree

    # For neovim
    nodejs
    npm
    python
    python-pip
    lua
    luarocks

    # Build tools (for compiling things)
    base-devel
    gcc
    make
    cmake
)

# AUR packages
AUR_PACKAGES=(
    # Shell enhancements
    zsh-syntax-highlighting
    zsh-autosuggestions
    oh-my-zsh-git

    # Prompt
    zsh-theme-powerlevel10k-git

    # CLI tools
    thefuck

    # Fonts (pick one or more)
    ttf-meslo-nerd-font-powerlevel10k
)

echo "Installing pacman packages..."
sudo pacman -S --needed --noconfirm "${PACMAN_PACKAGES[@]}"

echo ""
echo "Installing AUR packages..."
for pkg in "${AUR_PACKAGES[@]}"; do
    if yay -Q "$pkg" &>/dev/null; then
        echo "Already installed: $pkg"
    else
        echo "Installing: $pkg"
        yay -S --noconfirm "$pkg" || echo "Failed to install $pkg, continuing..."
    fi
done

echo ""
echo "=== Setting up Rust (for additional tools) ==="
if ! command -v cargo &> /dev/null; then
    echo "Installing Rust..."
    curl --proto '=https' --tlsv1.2 -sSf https://sh.rustup.rs | sh -s -- -y
    source "$HOME/.cargo/env"
else
    echo "Rust already installed"
fi

echo ""
echo "=== Setting up Zsh ==="

# Set zsh as default shell if not already
if [[ "$SHELL" != *"zsh"* ]]; then
    echo "Setting zsh as default shell..."
    chsh -s $(which zsh)
fi

# Create .zshrc if it doesn't exist
if [[ ! -f "$HOME/.zshrc" ]]; then
    echo "Creating .zshrc..."
    cat > "$HOME/.zshrc" << 'ZSHRC_EOF'
# Enable Powerlevel10k instant prompt
if [[ -r "${XDG_CACHE_HOME:-$HOME/.cache}/p10k-instant-prompt-${(%):-%n}.zsh" ]]; then
  source "${XDG_CACHE_HOME:-$HOME/.cache}/p10k-instant-prompt-${(%):-%n}.zsh"
fi

# Path to oh-my-zsh installation
export ZSH="$HOME/.oh-my-zsh"

# Theme (will be overridden by p10k)
ZSH_THEME="robbyrussell"

# Plugins
plugins=(
    git
    docker
    kubectl
    fzf
    zoxide
)

# Load oh-my-zsh
source $ZSH/oh-my-zsh.sh

# Load custom configurations (from dotfiles)
for config in $ZSH/custom/*.zsh; do
    [[ -f "$config" ]] && source "$config"
done

# Load Arch-specific init
[[ -f "$ZSH/custom/init-arch.zsh" ]] && source "$ZSH/custom/init-arch.zsh"
ZSHRC_EOF
fi

echo ""
echo "=== Setting up tmux plugin manager ==="
if [[ ! -d "$HOME/.tmux/plugins/tpm" ]]; then
    echo "Installing tpm..."
    git clone https://github.com/tmux-plugins/tpm ~/.tmux/plugins/tpm
else
    echo "tpm already installed"
fi

echo ""
echo "=== Stowing Dotfiles ==="

if [[ ! -d "$DOTFILES_DIR" ]]; then
    echo "Error: Dotfiles directory not found at $DOTFILES_DIR"
    echo "Please clone your dotfiles repo first:"
    echo "  git clone <your-dotfiles-repo> $DOTFILES_DIR"
    exit 1
fi

cd "$DOTFILES_DIR"

# Directories to stow for Arch (minimal set)
STOW_DIRS=(
    nvim
    tmux
    zsh
    starship
    lsd
)

for dir in "${STOW_DIRS[@]}"; do
    if [[ ! -d "$DOTFILES_DIR/$dir" ]]; then
        echo "Skipping $dir (directory not found in dotfiles)"
        continue
    fi

    echo "Stowing: $dir"
    # Use --adopt to handle existing files, then restore from git
    stow --adopt "$dir" 2>/dev/null || stow "$dir" || echo "Failed to stow $dir, continuing..."
done

# Restore any adopted files to repo versions
echo "Restoring dotfiles to repo versions..."
git checkout -- . 2>/dev/null || true

echo ""
echo "=== Post-install Notes ==="
echo ""
echo "1. Restart your terminal or run: exec zsh"
echo ""
echo "2. Run 'p10k configure' to set up your prompt"
echo ""
echo "3. In tmux, press prefix + I (Ctrl-a + I) to install plugins"
echo ""
echo "4. In neovim, plugins will auto-install on first launch"
echo ""
echo "5. Copy your secrets to ~/.oh-my-zsh/custom/secrets.zsh (not tracked by git)"
echo ""
echo "=== Setup Complete ==="
