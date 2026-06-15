" ~/.config/nvim/compiler/swiftpm.vim
" Build Swift Package Manager project (release)
setlocal makeprg=swift\ build\ -c\ release
setlocal errorformat=%f:%l:%c:\ %m
