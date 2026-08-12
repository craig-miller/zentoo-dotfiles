-- https://github.com/jbuck95/nvim-sioyek-highlights
-- Reads sioyek's ~/.local/share/sioyek/shared.db highlight store; telescope
-- picker inserts the selected highlight into the current buffer.
--   <leader>sh  pick a highlight (plugin default)
--   <leader>sj  jump from citation to the highlight's page in sioyek (plugin default)
-- format_function only receives `text` — no page/doc/citekey metadata. Cards
-- created via <leader>pz already carry the paper's citekey in their body, so
-- a bare Typst #quote is enough (the surrounding card provides attribution).
return {
    "jbuck95/nvim-sioyek-highlights",
    dependencies = { "nvim-telescope/telescope.nvim" },
    ft = { "typst", "markdown" },
    cmd = { "SioyekHighlights", "SioyekJump" },
    keys = {
        { "<leader>sh", "<cmd>SioyekHighlights<cr>", desc = "Sioyek highlights" },
        { "<leader>sj", "<cmd>SioyekJump<cr>",       desc = "Sioyek jump to highlight" },
    },
    opts = {
        db_path = "~/.local/share/sioyek/shared.db",
        format_function = function(text)
            return "#quote[" .. text .. "]"
        end,
    },
    config = function(_, opts)
        require("sioyek-highlights").setup(opts)
    end,
}
