#!/bin/bash

# Directory to save the package lists (same directory as the script)
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" &>/dev/null && pwd)"

# Check if a command exists
command_exists() {
  command -v "$1" >/dev/null 2>&1
}

# Save installed Homebrew packages to Brewfile
save_brew_packages() {
  if command_exists brew; then
    echo "Saving installed Homebrew packages to Brewfile..."
    brew bundle dump --file="$SCRIPT_DIR/Brewfile" --force
  else
    echo "Homebrew not found, skipping."
  fi
}

# Save installed Cargo packages to cargo.txt
save_cargo_packages() {
  if command_exists cargo; then
    echo "Saving installed Cargo packages to cargo.txt..."
    cargo install --list | awk '/^[[:alnum:]]/ {print $1}' >"$SCRIPT_DIR/cargo.txt"
  else
    echo "Cargo not found, skipping."
  fi
}

# Save installed Yarn packages to yarn.txt
save_yarn_packages() {
  if command_exists yarn; then
    echo "Saving installed Yarn packages to yarn.txt..."
    yarn global list --depth=0 | awk '/info "/ {print $2}' >"$SCRIPT_DIR/yarn.txt"
  else
    echo "Yarn not found, skipping."
  fi
}

# Save installed npm packages to npm.txt
save_npm_packages() {
  if command_exists npm; then
    echo "Saving installed npm packages to npm.txt..."
    npm list -g --depth=0 | grep '├──' | awk '{print $2}' >"$SCRIPT_DIR/npm.txt"
  else
    echo "npm not found, skipping."
  fi
}

# Save installed Gem packages to gemfile
save_gem_packages() {
  if command_exists gem; then
    echo "Saving installed Gem packages to gemfile..."
    gem list --local | awk '{print $1}' >"$SCRIPT_DIR/gemfile"
  else
    echo "Gem not found, skipping."
  fi
}

# Save installed pip3 packages to pip.txt
save_pip3_packages() {
  if command_exists pip3; then
    echo "Saving installed pip3 packages to pip.txt..."
    pip3 freeze >"$SCRIPT_DIR/pip.txt"
  else
    echo "pip3 not found, skipping."
  fi
}

# Save installed Golang packages to go.txt
save_golang_packages() {
  if command_exists go; then
    echo "Saving installed Golang packages to go.txt..."
    go list -m -f '{{if not (or .Main .Indirect)}}{{.Path}}{{end}}' all >"$SCRIPT_DIR/go.txt"
  else
    echo "Golang not found, skipping."
  fi
}

# Main process
save_brew_packages
save_cargo_packages
save_yarn_packages
save_npm_packages
save_gem_packages
save_pip3_packages
save_golang_packages

echo "All installed packages have been saved to the corresponding files."
