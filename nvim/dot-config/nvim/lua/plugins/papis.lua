return {
    "jghauser/papis.nvim",
    ft = { "markdown", "typst", "yaml" },
    dependencies = {
        "saghen/blink.cmp",
        "kkharji/sqlite.lua",
        "MunifTanjim/nui.nvim",
        {
            "folke/snacks.nvim",
            opts = { picker = { enabled = true } },
        },
    },
    config = function()
        require("papis").setup({
            ["search"] = { enable = true },
            ["completion"] = { enable = true },
            ["at-cursor"] = { enable = true },
            ["formatter"] = { enable = true },
            ["base"] = { enable = true },
            papis_python = {
                dir = vim.fn.expand("~/docs/papers"),
                info_name = "info.yaml",
                notes_name = "notes.md",
            },
            cite_formats = {
                typst = { start = "@", ["end"] = "", format = "%s" },
                markdown = { start = "[@", ["end"] = "]", format = "%s" },
                yaml = { start = "@", ["end"] = "", format = "%s" },
            },
            init_filetypes = { "markdown", "typst", "yaml" },
        })

        -- Explicit keymaps (papis.nvim's defaults do not register on this setup)
        local map = function(lhs, rhs, desc)
            vim.keymap.set("n", lhs, rhs, { desc = desc })
        end
        map("<leader>pp", "<cmd>Papis search<cr>",                "Papis: search library")
        map("<leader>pi", "<cmd>Papis at-cursor show-popup<cr>",  "Papis: info popup")
        map("<leader>pf", "<cmd>Papis at-cursor open-file<cr>",   "Papis: open PDF")
        map("<leader>pn", "<cmd>Papis at-cursor open-note<cr>",   "Papis: open notes")
        map("<leader>pe", "<cmd>Papis at-cursor edit<cr>",        "Papis: edit info.yaml")
    end,
}
