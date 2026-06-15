-- Fallback colorscheme for tinty schemes that don't have a dedicated plugin
-- (e.g. Twilight). RRethy/base16-nvim reads the active scheme via base16-vim's
-- API; we drive it with `:colorscheme base16-<slug>` from the switcher.
return {
    "RRethy/base16-nvim",
    lazy = true,
    priority = 1000,
}
