# eza — modern ls replacement (no --icons; no Nerd Font installed).
abbr -a ls 'eza'
abbr -a ll 'eza -l --git'
abbr -a la 'eza -la --git'
abbr -a lt 'eza --tree --git-ignore'

# stow with our dotfiles flags — --dotfiles for dot-* path mangling,
# --no-folding to force per-file symlinks (avoid directory-level),
# -R to restow (handles fresh stow, restow, and adding-new-files).
abbr -a --position command stow 'stow --dotfiles --no-folding -R'
