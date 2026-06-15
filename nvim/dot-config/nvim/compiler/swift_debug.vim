" ~/.config/nvim/compiler/swift_debug.vim
" Compile standalone Swift file (debug)
setlocal makeprg=swiftc\ -g\ %\ -o\ %:r
setlocal errorformat=%f:%l:%c:\ %m
