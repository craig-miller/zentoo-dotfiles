function po --description 'pick a pass entry with an OTP secret, show ticking code, copy on Enter'
    set -l entry (find ~/.password-store -name '*.gpg' -printf '%P\n' | string replace -r '\.gpg$' '' | fzf --prompt='otp> ')
    test -z "$entry"; and return
    bash -c '
        entry="$1"
        if ! pass otp "$entry" >/dev/null 2>&1; then
            echo "no OTP secret in pass entry: $entry" >&2
            exit 1
        fi
        while true; do
            code=$(pass otp "$entry")
            now=$(date +%s)
            remaining=$((30 - now % 30))
            printf "\r\033[K%s  expires in %2ds  [Enter=copy, Ctrl-C=cancel] " "$code" "$remaining"
            if read -s -t 1 _; then
                printf "\r\033[K"
                PASSWORD_STORE_CLIP_TIME=$remaining pass otp -c "$entry" >/dev/null 2>&1
                exit 0
            fi
        done
    ' _ "$entry"
end
