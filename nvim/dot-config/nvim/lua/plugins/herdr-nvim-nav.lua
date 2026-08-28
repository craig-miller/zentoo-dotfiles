return {
    "aimdevlee/herdr-nvim-nav",
    lazy = false,
    config = function()
        require("herdr-nvim-nav").setup({
            -- We are using herdr directly, not tmux. Avoid requiring
            -- christoomey/vim-tmux-navigator as a fallback dependency.
            with_tmux = false,
        })
    end,
}
