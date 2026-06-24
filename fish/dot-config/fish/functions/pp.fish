function pp --description 'pick a pass entry and copy to clipboard'
    set -l entry (find ~/.password-store -name '*.gpg' -printf '%P\n' | string replace -r '\.gpg$' '' | fzf --prompt='pass> ')
    test -n "$entry"; and pass -c "$entry" >/dev/null 2>&1
end
