# vector colorway for fzf — source from zsh init.
# Crimson pointer/prompt (sessions channel), amber match highlight, panel
# selection fill. Pickers launched from tmux pass their own frame colors.
export FZF_DEFAULT_OPTS="${FZF_DEFAULT_OPTS:+$FZF_DEFAULT_OPTS }\
--color=bg:-1,bg+:#1c2e4a,fg:#c8d8ea,fg+:#eaf4ff,hl:#f0b429,hl+:#f0b429 \
--color=pointer:#ff5d73,prompt:#ff5d73,marker:#22d3ee,spinner:#22d3ee \
--color=info:#3d4f6b,header:#5a7290,gutter:-1,border:#1a2332,query:#c8d8ea \
--pointer='▸' --marker='◆'"
