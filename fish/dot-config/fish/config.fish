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

    # bat — syntax-highlighted cat. ANSI theme follows the terminal palette
    # (alacritty pulls noctalia's M3 colors), so bat retints with the wallpaper.
    set -gx BAT_THEME ansi
    set -gx MANPAGER "sh -c 'col -bx | bat -l man -p'"

    # yazi — TUI file manager. `yy` runs yazi and cd's into the last visited
    # directory on exit (upstream's official cwd-on-exit pattern).
    function yy
        set -l tmp (mktemp -t "yazi-cwd.XXXXXX")
        yazi $argv --cwd-file="$tmp"
        if read -z cwd <"$tmp"; and [ -n "$cwd" ]; and [ "$cwd" != "$PWD" ]
            builtin cd -- "$cwd"
        end
        rm -f -- "$tmp"
    end
end
