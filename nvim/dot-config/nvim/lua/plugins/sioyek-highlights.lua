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
        -- format_function must return a table of strings (each element = one
        -- line — the plugin passes it straight to nvim_buf_set_text). PDFs
        -- often hard-wrap mid-sentence, so collapse whitespace to a single
        -- flowing line before wrapping in Typst's #quote[].
        --
        -- Attribution: the plugin only hands us `text`, not the source paper's
        -- citekey. Derive it from the buffer path — papis lays out both
        --   ~/research/papers/<ref>/notes.typ  (paper reviews)
        --   ~/research/notes/<ref>-<slug>.typ  (grounded cards)
        -- with the citekey encoded. Fall back to a bare #quote when no ref
        -- can be inferred (buffer somewhere else in the vault).
        format_function = function(text)
            local flat = text:gsub("%s+", " "):gsub("^%s+", ""):gsub("%s+$", "")
            local bufname = vim.api.nvim_buf_get_name(0)
            local ref = bufname:match("/research/papers/([^/]+)/notes%.typ$")
                     or bufname:match("/research/notes/([^-/]+)%-")
            -- block: true + quotes: true come from `#set quote(...)` in
            -- ~/research/templates/note.typ, so we emit bare #quote() here.
            if ref then
                return { "#quote(attribution: [@" .. ref .. "])[" .. flat .. "]" }
            end
            return { "#quote[" .. flat .. "]" }
        end,
    },
    config = function(_, opts)
        require("sioyek-highlights").setup(opts)
    end,
}
