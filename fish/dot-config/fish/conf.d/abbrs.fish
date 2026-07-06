# eza — modern ls replacement. --icons pulls file-type glyphs from the
# system monospace font (JetBrainsMono Nerd Font Mono, per Step 3).
abbr -a ls 'eza --icons'
abbr -a ll 'eza -l --git --icons'
abbr -a la 'eza -la --git --icons'
abbr -a lt 'eza --tree --git-ignore --icons'

# stow with our dotfiles flags — --dotfiles for dot-* path mangling,
# --no-folding to force per-file symlinks (avoid directory-level),
# -R to restow (handles fresh stow, restow, and adding-new-files).
abbr -a --position command stow 'stow --dotfiles --no-folding -R'
