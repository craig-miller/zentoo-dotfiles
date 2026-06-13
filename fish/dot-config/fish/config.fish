if status is-interactive
    # Quiet greeting
    set -U fish_greeting ""

    # Vi keybindings
    fish_vi_key_bindings

    # Starship prompt (uncomment after emerging app-shells/starship)
    starship init fish | source
end
