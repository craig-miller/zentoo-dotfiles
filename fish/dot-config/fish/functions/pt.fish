function pt --description 'pick a pass entry and type into previously-focused window'
    set -l entry (find ~/.password-store -name '*.gpg' -printf '%P\n' | string replace -r '\.gpg$' '' | fzf --prompt='pass-type> ')
    test -z "$entry"; and return
    set -l pw (pass "$entry" | head -1 | string trim)
    test -z "$pw"; and return
    niri msg action focus-window-previous >/dev/null 2>&1
    sleep 0.15
    wtype -- "$pw"
end
