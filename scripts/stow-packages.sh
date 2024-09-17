#!/bin/bash

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PARENT_DIR="$(dirname "$SCRIPT_DIR")"

EXCLUDED=("scripts" "readme.md" ".git" ".DS_Store")

should_exclude() {
  local item_lowercase=$(echo "$1" | tr '[:upper:]' '[:lower:]')
  for exclude in "${EXCLUDED[@]}"; do
    local exclude_lowercase=$(echo "$exclude" | tr '[:upper:]' '[:lower:]')
    if [[ "$item_lowercase" == "$exclude_lowercase" ]]; then
      return 0
    fi
  done
  return 1
}

for item in "$PARENT_DIR"/*; do
  base_item="$(basename "$item")"

  if [[ -f "$item" ]] || [[ "$base_item" == .* ]] || should_exclude "$base_item"; then
    continue
  fi

  echo "Running stow on $base_item..."
  stow -v -d "$PARENT_DIR" -t "$HOME" "$base_item"
done
