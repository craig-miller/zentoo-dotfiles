return {
    "voldikss/vim-floaterm",
    lazy = true,
    keys = {
        -- { "<leader>tt", "<cmd>FloatermToggle<cr>", desc = "Terminal", mode = { "n", "v" } },
        -- { "<leader>tt", "<cmd>FloatermToggle<cr>", desc = "Terminal", mode = { "t" } },
        { "<C-esc>", "<cmd>FloatermToggle<cr>",            desc = "Terminal", mode = { "n", "v" } },
        { "<C-esc>", "<C-\\><C-n><CMD>FloatermToggle<CR>", desc = "Close",    mode = { "t" } },
        -- { "<leader>wb", "<cmd>FloatermNew ignite build<cr>",         desc = "Website Build", mode = { "n", "v" } },
        -- { "<leader>wr", "<cmd>FloatermNew ignite run --preview<cr>", desc = "Website Run",   mode = { "n", "v" } },
        -- { "<leader>wp", "<cmd>TODO<cr>", desc = "Website Publish", mode = { "n", "v" } },
    },
}
