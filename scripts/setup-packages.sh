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

install_lua() {
  if ! command_exists lua; then
    echo "Installing Lua"
    brew install lua
  fi
}

install_gum() {
  if ! command_exists gum; then
    echo "Installing Gum"
    brew install gum
  fi
}

install_homebrew
install_lua
install_gum

lua setup-packages.lua
