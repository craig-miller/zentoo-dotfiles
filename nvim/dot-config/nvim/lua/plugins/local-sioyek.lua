-- Lazy spec for the local sioyek module. Points at the in-tree
-- ~/.config/nvim/lua/local/sioyek/ directory (dir=), not an external repo.
return {
    dir = vim.fn.stdpath("config") .. "/lua/local/sioyek",
    name = "local-sioyek",
    lazy = false,
    dependencies = { "nvim-telescope/telescope.nvim" },
    keys = {
        {
            "<leader>ph",
            function() require("local.sioyek").pick_highlights() end,
            desc = "Insert highlight",
        },
        {
            "<leader>ps",
            function() require("local.sioyek").jump_to_source() end,
            desc = "Show highlight in PDF",
        },
    },
}
