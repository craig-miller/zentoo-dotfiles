function __zoxide_picker
    set -l dir (zoxide query -i 2>/dev/null)
    if test -n "$dir"
        builtin cd -- "$dir"
        commandline -f repaint
    end
end
