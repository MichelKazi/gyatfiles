# Shared interactive shell bootstrap. Personal secrets belong in ignored files.
export PATH="$HOME/bin:$HOME/.local/bin:$PATH"

[[ $- == *i* ]] || return

if [[ "$OSTYPE" == linux* && -r /usr/share/oh-my-zsh/oh-my-zsh.sh ]]; then
  export ZSH=/usr/share/oh-my-zsh
else
  export ZSH="$HOME/.oh-my-zsh"
fi
ZSH_THEME=""
plugins=(git)
[[ -r "$ZSH/oh-my-zsh.sh" ]] && source "$ZSH/oh-my-zsh.sh"

for config in "$HOME"/.config/gyatfiles/zsh/custom/*.zsh; do
  [[ -r "$config" ]] && source "$config"
done

command -v starship >/dev/null 2>&1 && eval "$(starship init zsh)"
[[ -r "$HOME/.zshrc.local" ]] && source "$HOME/.zshrc.local"
