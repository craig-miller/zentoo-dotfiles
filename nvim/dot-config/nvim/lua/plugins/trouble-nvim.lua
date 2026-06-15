return {
    "folke/trouble.nvim",
    opts = {}, -- for default options, refer to the configuration section for custom setup.
    cmd = "Trouble",
    keys = {
        {
            "<leader>td",
            "<cmd>Trouble diagnostics toggle<cr>",
            desc = "Diagnostics",
        },
        {
            "<leader>tD",
            "<cmd>Trouble diagnostics toggle filter.buf=0<cr>",
            desc = "Buffer Diagnostics",
        },
        {
            "<leader>ts",
            "<cmd>Trouble symbols toggle focus=true win.position=left<cr>",
            desc = "Toggle Code Symbols",
        },
        {
            "<leader>cl",
            "<cmd>Trouble lsp toggle focus=false win.position=left<cr>",
            desc = "LSP Definitions / references / ...",
        },
        {
            "<leader>tl",
            "<cmd>Trouble loclist toggle<cr>",
            desc = "Location List",
        },
        {
            "<leader>tq",
            "<cmd>Trouble qflist toggle<cr>",
            desc = "Quickfix List",
        },
    },
}
