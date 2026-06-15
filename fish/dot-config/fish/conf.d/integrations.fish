status is-interactive; or exit

# Starship prompt
starship init fish | source

# zoxide — smart cd. `z <pat>` jumps; `zi` opens an interactive fzf picker.
# Disable XOFF flow control so the terminal driver doesn't swallow Ctrl+S.
stty -ixon 2>/dev/null
zoxide init fish | source
