# Arch Linux / Steam Deck aliases
# Platform-agnostic aliases that work on Linux

## Directories
alias downloads="cd ~/Downloads"
alias docs="cd ~/Documents"
alias projects="cd ~/projects"
alias gyatfiles="cd ~/gyatfiles"
alias ..="cd .."

# Misc config shortcuts
alias vrc="nvim ~/gyatfiles/nvim/.config/nvim/"
alias ctmux="nvim ~/gyatfiles/tmux/.tmux.conf"
alias czsh="nvim ~/.oh-my-zsh/custom"
alias szsh="source ~/.zshrc"

## Editor
alias vim="nvim"
alias nv="nvim"
alias v="nvim"

## File operations
alias ls="lsd"
alias ll="lsd -la"
alias la="lsd -a"
alias lt="lsd --tree"
alias back="cd -"

## Safety
alias rm="echo 'Use rip or /bin/rm directly'"

## Git shortcuts (supplement oh-my-zsh git plugin)
alias lg="lazygit"

## Python
alias py="python"
alias py3="python3"

## Misc
alias readme="nvim README.md"
alias pls="sudo"
alias copydir="pwd | xclip -selection clipboard"
