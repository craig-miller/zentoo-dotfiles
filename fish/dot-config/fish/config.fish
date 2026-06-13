if status is-interactive
    # Quiet greeting
    set -U fish_greeting ""

    # Vi keybindings
    fish_vi_key_bindings

    # Starship prompt
    starship init fish | source

    # eza — modern ls replacement (no --icons; no Nerd Font installed)
    abbr -a ls 'eza'
    abbr -a ll 'eza -l --git'
    abbr -a la 'eza -la --git'
    abbr -a lt 'eza --tree --git-ignore'

    # fzf — fuzzy finder. Native Ctrl+R history widget.
    # Free Ctrl+T (reserved); rebind file widget to Ctrl+F.
    # fzf binds in both default and insert mode, so we mirror in both.
    fzf --fish | source
    bind --erase \ct
    bind -M insert --erase \ct
    bind \cf fzf-file-widget
    bind -M insert \cf fzf-file-widget
end
