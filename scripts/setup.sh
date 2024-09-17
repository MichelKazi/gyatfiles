#!/bin/bash

command_exists() {
  command -v "$1" >/dev/null 2>&1
}

install_homebrew() {
  if ! command_exists brew; then
    echo "Installing Homebrew"
    /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
  else
    echo "Homebrew is already installed."
  fi
}

install_tools() {
  echo "Installing setup tools"

  if ! command_exists gum; then
    echo "Installing Gum"
    brew install gum
  else
    echo "gum is already installed"
  fi

  if ! command_exists lua; then
    gum spin --spinner moon --title="Installing lua" -- brew install lua
  else
    echo "Lua is already installed"
  fi

  if ! command_exists stow; then
    gum spin --spinner moon --title="Installing stow" -- brew install stow
  else
    echo "stow is already installed"
  fi
}

setup_shell() {
  if [ -d "$HOME/.oh-my-zsh" ]; then
    echo ".oh-my-zsh directory exists in the home directory."
  else
    sh -c "$(curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)"
  fi
}

setup_sync_packages() {
  SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
  SCRIPT_PATH="$SCRIPT_DIR/sync-installed-packages.sh"
  PLIST_PATH="$SCRIPT_DIR/launchd/com.kazi.syncinstalledpackages.plist"
  LAUNCH_AGENTS_DIR="$HOME/Library/LaunchAgents"
  PLIST_NAME="com.kazi.syncinstalledpackages.plist"
  PLIST_DEST="$LAUNCH_AGENTS_DIR/$PLIST_NAME"

  if [ -f "$SCRIPT_PATH" ]; then
    echo "Making $SCRIPT_PATH executable..."
    chmod +x "$SCRIPT_PATH"
  else
    echo "Error: $SCRIPT_PATH not found!"
    exit 1
  fi

  if [ -f "$PLIST_PATH" ]; then
    echo "Moving $PLIST_PATH to $LAUNCH_AGENTS_DIR..."
    mv "$PLIST_PATH" "$PLIST_DEST"
  else
    echo "Error: $PLIST_PATH not found!"
    exit 1
  fi

  echo "Loading the Launch Agent..."
  launchctl load "$PLIST_DEST"

  if launchctl list | grep -q "com.kazi.syncinstalledpackages"; then
    echo "Launch Agent com.kazi.syncinstalledpackages is successfully loaded and running."
  else
    echo "Error: Failed to load the Launch Agent."
    exit 1
  fi
}

setup() {
  chmod +x sync-installed-packages.sh
  ./stow-packages.sh
  install_homebrew
  install_tools
  setup_sync_packages
  gum spin --spinner moon --title="Running the Lua script to install package managers and packages..." -- lua setup-packages.lua
}

setup
