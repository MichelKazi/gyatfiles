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

run_lua_script() {
  gum spin --spinner moon --title="Running the Lua script to install package managers and packages..." -- lua setup-packages.lua
  LUA_EXIT_CODE=$?

  if [ $LUA_EXIT_CODE -eq 0 ]; then
    echo "Lua script ran successfully!"
    return 0
  else
    echo "Lua script failed with exit code $LUA_EXIT_CODE."
    return 1
  fi
}

# Function to prompt user to restart shell
prompt_restart_shell() {
  if gum confirm "Do you want to restart your shell now?"; then
    gum spin --spinner moon --title="Restarting the shell..." -- exec $SHELL
  else
    echo "Shell restart skipped. Please restart your shell manually if needed."
  fi
}

# Run the Lua script
if run_lua_script; then
  # If the Lua script succeeded, prompt for shell restart
  prompt_restart_shell
else
  echo "There was an issue running the Lua script. Please check the output for errors."
fi
