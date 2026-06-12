-- Minimal neovim config. Uses the terminal's 16-color ANSI palette so
-- colors track ghostty's theme — which Noctalia paints from the active
-- wallpaper's M3 palette. No GUI true colors, no separate colorscheme —
-- neovim's default highlighting maps to cterm slots, and the terminal
-- renders them in its current theme.

vim.opt.termguicolors = false
vim.opt.background = "dark"

vim.opt.number = true
vim.opt.relativenumber = true
vim.opt.cursorline = true
vim.opt.expandtab = true
vim.opt.tabstop = 4
vim.opt.shiftwidth = 4
vim.opt.smartindent = true
vim.opt.ignorecase = true
vim.opt.smartcase = true
vim.opt.mouse = "a"
vim.opt.scrolloff = 4
vim.opt.signcolumn = "yes"
vim.opt.undofile = true
vim.opt.clipboard = "unnamedplus"

vim.g.mapleader = " "
