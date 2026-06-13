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
end
