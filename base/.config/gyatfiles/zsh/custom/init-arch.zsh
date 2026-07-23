[[ "$OSTYPE" == linux* ]] || return

# Arch Linux / Steam Deck specific initialization
# This file is sourced instead of init.zsh on Arch systems

# Auto-start tmux if not already in a tmux session
if [[ -z "$TMUX" && -z "${DOTFILES_NO_TMUX:-}" ]] && command -v tmux >/dev/null 2>&1; then
    tmux new -A -s BASE
fi

# Completion cache optimization (GNU stat version)
autoload -Uz compinit
zcompdump_date=$(stat -c '%j' ~/.zcompdump 2>/dev/null || echo "0")
today=$(date +'%j')
if [ "$today" != "$zcompdump_date" ]; then
    compinit
else
    compinit -C
fi

# Environment
export EDITOR='nvim'
export VISUAL='nvim'

# PATH additions
export PATH="$HOME/.local/bin:$PATH"
export PATH="$HOME/bin:$PATH"
export PATH="$HOME/.cargo/bin:$PATH"

# Go path (if go is installed)
if command -v go &> /dev/null; then
    export PATH="$PATH:$(go env GOPATH)/bin"
fi

# fnm (fast node manager) - if installed
if command -v fnm &> /dev/null; then
    eval "$(fnm env)"
    alias nvm=fnm
fi

# Plugin paths for Arch Linux
# zsh-syntax-highlighting
if [[ -f /usr/share/zsh/plugins/zsh-syntax-highlighting/zsh-syntax-highlighting.zsh ]]; then
    source /usr/share/zsh/plugins/zsh-syntax-highlighting/zsh-syntax-highlighting.zsh
elif [[ -f /usr/share/zsh-syntax-highlighting/zsh-syntax-highlighting.zsh ]]; then
    source /usr/share/zsh-syntax-highlighting/zsh-syntax-highlighting.zsh
fi

# zsh-autosuggestions
if [[ -f /usr/share/zsh/plugins/zsh-autosuggestions/zsh-autosuggestions.zsh ]]; then
    source /usr/share/zsh/plugins/zsh-autosuggestions/zsh-autosuggestions.zsh
elif [[ -f /usr/share/zsh-autosuggestions/zsh-autosuggestions.zsh ]]; then
    source /usr/share/zsh-autosuggestions/zsh-autosuggestions.zsh
fi

# zoxide (smart cd)
if command -v zoxide &> /dev/null; then
    eval "$(zoxide init zsh)"
fi

# thefuck
if command -v thefuck &> /dev/null; then
    eval $(thefuck --alias)
fi
