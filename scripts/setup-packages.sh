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

./stow-packages.sh
install_homebrew
install_tools

gum spin --spinner moon --title="Running the Lua script to install package managers and packages..." -- lua setup-packages.lua
