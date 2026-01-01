if [ -z "$TMUX" ]; then
  tmux new -A -s BASE
fi

# Only rebuild completion cache once
autoload -Uz compinit
if [ "$(date +'%j')" != "$(stat -f '%Sm' -t '%j' ~/.zcompdump 2>/dev/null)" ]; then
    compinit
else
    compinit -C
fi



# export MANPATH="/usr/local/man:$MANPATH"

# You may need to manually set your language environment
# export LANG=en_US.UTF-8

# Preferred editor for local and remote sessions
# if [[ -n $SSH_CONNECTION ]]; then
#   export EDITOR='vim'
# else
#   export EDITOR='mvim'
# fi

# Compilation flags
# export ARCHFLAGS="-arch x86_64"

# Set personal aliases, overriding those provided by oh-my-zsh libs,
# plugins, and themes. Aliases can be placed here, though oh-my-zsh
# users are encouraged to define aliases within the ZSH_CUSTOM folder.
# For a full list of active aliases, run `alias`.
#
# Example aliases
# alias zshconfig="mate ~/.zshrc"
# alias ohmyzsh="mate ~/.oh-my-zsh"

# $PATH
export PATH=${PATH}:`go env GOPATH`/bin
export PATH=${PATH}:~/bin
export PATH="$PATH:/Users/mkazi/.local/bin"
export PATH="$HOME/.canary-tools/bin:$PATH"
export PATH="$HOME/bin:$PATH"
export PATH="$PATH:/Applications/WezTerm.app/Contents/MacOS"

# Shit that's supposed to go at the end

# fnm
FNM_PATH="/opt/homebrew/opt/fnm/bin"
if [ -d "$FNM_PATH" ]; then
  eval "`fnm env`"
fi
alias nvm=fnm

# SDKMAN lazy loading
export SDKMAN_DIR="$HOME/.sdkman"
SDKMAN_LOADED=false

load_sdkman() {
  if [[ "$SDKMAN_LOADED" = false ]]; then
    [[ -s "$SDKMAN_DIR/bin/sdkman-init.sh" ]] && source "$SDKMAN_DIR/bin/sdkman-init.sh"
    SDKMAN_LOADED=true
  fi
}

sdk() {
  load_sdkman
  command sdk "$@"
}
# for scala
sdkman_auto_load() {
  if [[ -f "build.sbt" ]] && [[ "$SDKMAN_LOADED" = false ]]; then
    load_sdkman
  fi
}
autoload -U add-zsh-hook
add-zsh-hook chpwd sdkman_auto_load
sdkman_auto_load
export PATH="/opt/homebrew/Cellar/openjdk@11/11.0.23/bin:$PATH"

source /opt/homebrew/share/zsh-syntax-highlighting/zsh-syntax-highlighting.zsh
source $(brew --prefix)/share/zsh-autosuggestions/zsh-autosuggestions.zsh
eval "$(zoxide init zsh)"
eval $(thefuck --alias)
eval "$(rbenv init - zsh)"

# Prompt
#
# --- Pure ---
# fpath+=("$(brew --prefix)/share/zsh/site-functions")
# autoload -U promptinit; promptinit
# prompt pure

# --- Starship ---
# The starship prompt doesn't work from here, so we'll call it from vanilla .zshrc
# eval "$(starship init zsh)" 

# --- P10K ---
source $(brew --prefix)/share/powerlevel10k/powerlevel10k.zsh-theme

# To customize prompt, run `p10k configure` or edit ~/.p10k.zsh.
[[ ! -f ~/.p10k.zsh ]] || source ~/.p10k.zsh
typeset -g POWERLEVEL9K_INSTANT_PROMPT=quiet
