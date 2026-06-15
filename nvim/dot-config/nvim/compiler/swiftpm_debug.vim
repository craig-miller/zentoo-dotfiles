" ~/.config/nvim/compiler/swiftpm_debug.vim
" Build Swift Package Manager project (debug)
setlocal makeprg=swift\ build\ -c\ debug
setlocal errorformat=%f:%l:%c:\ %m
