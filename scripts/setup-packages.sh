#!/bin/bash

# Directory containing the package lists
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" &>/dev/null && pwd)"

# Define available package managers
PACKAGE_MANAGERS=(
  "Homebrew"
  "Cargo"
  "Yarn"
  "npm"
  "Gem"
  "pip3"
  "SDKMAN"
  "Golang"
)

# Check if a command exists
command_exists() {
  type -v "$1" >/dev/null 2>&1
}

# Install Gum if not installed
install_gum() {
  if ! command_exists gum; then
    echo "Gum not found. Installing Gum via Homebrew..."
    brew install gum
  fi
}

# Function to present the selection menu using Gum
select_package_managers() {
  echo "Select package managers to install (use space to select):"
  local choices=$(gum choose --no-limit --cursor.foreground="#00ff00" "${PACKAGE_MANAGERS[@]}")
  echo "$choices"
}

# Function to run an installation step with a progress bar
run_with_progress() {
  local title="$1"
  local command="$2"
  echo "Installing $title..."
  $command 2>&1 | gum spin --title "Installing $title..." --spinner dot
}

# Install Homebrew if selected
install_homebrew() {
  if [[ " ${selected[@]} " =~ " Homebrew " ]]; then
    if ! command_exists brew; then
      run_with_progress "Homebrew" "/bin/bash -c \"\$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)\""
    else
      echo "Homebrew already installed."
    fi
  fi
}

# Install packages from Homebrew
install_brew_packages() {
  if [[ " ${selected[@]} " =~ " Homebrew " ]] && [ -f "$SCRIPT_DIR/Brewfile" ]; then
    run_with_progress "Homebrew packages" "brew bundle --file=$SCRIPT_DIR/Brewfile"
  fi
}

# Install Cargo if selected
install_cargo() {
  if [[ " ${selected[@]} " =~ " Cargo " ]]; then
    if ! command_exists cargo; then
      run_with_progress "Cargo" "curl --proto '=https' --tlsv1.2 -sSf https://sh.rustup.rs | sh"
    else
      echo "Cargo already installed."
    fi
  fi
}

# Install packages from Cargo
install_cargo_packages() {
  if [[ " ${selected[@]} " =~ " Cargo " ]] && [ -f "$SCRIPT_DIR/cargo.txt" ]; then
    run_with_progress "Cargo packages" "cat $SCRIPT_DIR/cargo.txt | xargs cargo install"
  fi
}

# Install Yarn if selected
install_yarn() {
  if [[ " ${selected[@]} " =~ " Yarn " ]]; then
    if ! command_exists yarn; then
      run_with_progress "Yarn" "npm install --global yarn"
    else
      echo "Yarn already installed."
    fi
  fi
}

# Install packages from Yarn
install_yarn_packages() {
  if [[ " ${selected[@]} " =~ " Yarn " ]] && [ -f "$SCRIPT_DIR/yarn.txt" ]; then
    run_with_progress "Yarn packages" "cat $SCRIPT_DIR/yarn.txt | xargs yarn global add"
  fi
}

# Install npm if selected
install_npm() {
  if [[ " ${selected[@]} " =~ " npm " ]]; then
    if ! command_exists npm; then
      run_with_progress "npm" "brew install node"
    else
      echo "npm already installed."
    fi
  fi
}

# Install packages from npm
install_npm_packages() {
  if [[ " ${selected[@]} " =~ " npm " ]] && [ -f "$SCRIPT_DIR/npm.txt" ]; then
    run_with_progress "npm packages" "cat $SCRIPT_DIR/npm.txt | xargs npm install -g"
  fi
}

# Install Gem if selected
install_gem() {
  if [[ " ${selected[@]} " =~ " Gem " ]]; then
    if ! command_exists gem; then
      run_with_progress "Gem" "brew install ruby"
    else
      echo "Gem already installed."
    fi
  fi
}

# Install packages from Gem
install_gem_packages() {
  if [[ " ${selected[@]} " =~ " Gem " ]] && [ -f "$SCRIPT_DIR/gemfile" ]; then
    run_with_progress "Gem packages" "cat $SCRIPT_DIR/gemfile | xargs gem install"
  fi
}

# Install pip3 if selected
install_pip3() {
  if [[ " ${selected[@]} " =~ " pip3 " ]]; then
    if ! command_exists pip3; then
      run_with_progress "pip3" "brew install python"
    else
      echo "pip3 already installed."
    fi
  fi
}

# Install packages from pip3
install_pip3_packages() {
  if [[ " ${selected[@]} " =~ " pip3 " ]] && [ -f "$SCRIPT_DIR/pip.txt" ]; then
    run_with_progress "pip3 packages" "pip3 install -r $SCRIPT_DIR/pip.txt"
  fi
}

# Install SDKMAN if selected
install_sdkman() {
  if [[ " ${selected[@]} " =~ " SDKMAN " ]]; then
    if ! command_exists sdk; then
      run_with_progress "SDKMAN" "curl -s https://get.sdkman.io | bash"
    else
      echo "SDKMAN already installed."
    fi
  fi
}

# Install SDKs from SDKMAN
install_sdkman_packages() {
  if [[ " ${selected[@]} " =~ " SDKMAN " ]] && [ -f "$SCRIPT_DIR/sdkman.txt" ]; then
    run_with_progress "SDKMAN packages" "cat $SCRIPT_DIR/sdkman.txt | xargs -I {} sdk install {}"
  fi
}

# Install Golang if selected
install_golang() {
  if [[ " ${selected[@]} " =~ " Golang " ]]; then
    if ! command_exists go; then
      run_with_progress "Golang" "brew install go"
    else
      echo "Golang already installed."
    fi
  fi
}

# Install packages from Golang
install_golang_packages() {
  if [[ " ${selected[@]} " =~ " Golang " ]] && [ -f "$SCRIPT_DIR/go.txt" ]; then
    run_with_progress "Golang packages" "cat $SCRIPT_DIR/go.txt | xargs -I {} go install {}"
  fi
}

# Main setup process
install_gum

# Prompt user to select package managers using Gum
selected=$(select_package_managers)

install_homebrew
install_brew_packages

install_cargo
install_cargo_packages

install_yarn
install_yarn_packages

install_npm
install_npm_packages

install_gem
install_gem_packages

install_pip3
install_pip3_packages

install_sdkman
install_sdkman_packages

install_golang
install_golang_packages

echo "All selected package managers and packages have been installed!"
