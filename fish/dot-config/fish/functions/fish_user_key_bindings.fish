function fish_user_key_bindings
    # fzf binds installed AFTER vi defaults so vi mode doesn't wipe them.
    # Native Ctrl+R history widget, plus the file-widget binds we override below.
    fzf --fish | source

    # Free Ctrl+T (reserved); rebind fzf file widget to Ctrl+F.
    # fzf binds in both default and insert mode, so mirror in both.
    bind --erase \ct
    bind -M insert --erase \ct
    bind \cf fzf-file-widget
    bind -M insert \cf fzf-file-widget

    # zoxide picker on Ctrl+S (Mac parity).
    bind \cs __zoxide_picker
    bind -M insert \cs __zoxide_picker
end
