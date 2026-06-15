" ~/.config/nvim/compiler/swift.vim
" Compile standalone Swift file (release)
setlocal makeprg=swiftc\ -O\ %\ -o\ %:r
setlocal errorformat=%f:%l:%c:\ %m
