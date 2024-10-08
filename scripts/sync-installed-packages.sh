#!/bin/bash

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" &>/dev/null && pwd)"

command_exists() {
  command -v "$1" >/dev/null 2>&1
}

save_brew_packages() {
  if command_exists brew; then
    echo "Saving installed Homebrew packages to Brewfile..."
    brew bundle dump --file="$SCRIPT_DIR/packages/Brewfile" --force
  else
    echo "Homebrew not found, skipping."
  fi
}

save_cargo_packages() {
  if command_exists cargo; then
    echo "Saving installed Cargo packages to cargo.txt..."
    cargo install --list | awk '/^[[:alnum:]]/ {print $1}' >"$SCRIPT_DIR/packages/cargo.txt"
  else
    echo "Cargo not found, skipping."
  fi
}

save_yarn_packages() {
  if command_exists yarn; then
    echo "Saving installed Yarn packages to yarn.txt..."
    yarn global list --depth=0 | awk '/info "/ {print $2}' >"$SCRIPT_DIR/packages/yarn.txt"
  else
    echo "Yarn not found, skipping."
  fi
}

save_npm_packages() {
  if command_exists npm; then
    echo "Saving installed npm packages to npm.txt..."
    npm list -g --depth=0 | grep '├──' | awk '{print $2}' >"$SCRIPT_DIR/packages/npm.txt"
  else
    echo "npm not found, skipping."
  fi
}

save_gem_packages() {
  if command_exists gem; then
    echo "Saving installed Gem packages to gemfile..."
    gem list --local | awk '{print $1}' >"$SCRIPT_DIR/packages/gemfile"
  else
    echo "Gem not found, skipping."
  fi
}

save_pip3_packages() {
  if command_exists pip3; then
    echo "Saving installed pip3 packages to pip.txt..."
    pip3 freeze >"$SCRIPT_DIR/packages/pip.txt"
  else
    echo "pip3 not found, skipping."
  fi
}

save_brew_packages
save_cargo_packages
save_yarn_packages
save_npm_packages
save_gem_packages
save_pip3_packages

echo "All installed packages have been saved to the corresponding files."
