#!/bin/sh

# Get active pane path
pane_path=$(tmux display-message -p -t "$TMUX_PANE" -F "#{pane_current_path}")

# Check if Git repo
if git -C "$pane_path" rev-parse --is-inside-work-tree >/dev/null 2>&1; then
  # Get Git root directory name
  git_root=$(basename "$(git -C "$pane_path" rev-parse --show-toplevel)")

  # Initialize status symbols
  symbols=""

  # Check for uncommitted changes (dirty)
  if [ -n "$(git -C "$pane_path" status --porcelain)" ]; then
    symbols="${symbols}" # Pencil
  fi

  # Check for conflicts
  if [ -n "$(git -C "$pane_path" diff --name-only --diff-filter=U)" ]; then
    symbols="${symbols}" # Skull
  fi

  # Check for stashed changes
  if [ -n "$(git -C "$pane_path" stash list)" ]; then
    symbols="${symbols}" # Floppy
  fi

  # Check upstream status
  upstream=$(git -C "$pane_path" rev-list --count --left-right @{u}...HEAD 2>/dev/null)
  if [ $? -eq 0 ]; then
    behind=$(echo "$upstream" | cut -f1)
    ahead=$(echo "$upstream" | cut -f2)

    if [ "$ahead" -gt 0 ] && [ "$behind" -gt 0 ]; then
      symbols="${symbols}󰦒" # Double arrow
    elif [ "$ahead" -gt 0 ]; then
      symbols="${symbols}" # Up arrow
    elif [ "$behind" -gt 0 ]; then
      symbols="${symbols}" # Down arrow
    fi
  fi

  # Combine elements with Git symbol
  echo " $git_root $symbols"
else
  # Fallback to directory name when not in Git repo
  basename "$pane_path"
fi
