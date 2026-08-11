-- Treesitter (nvim-treesitter main branch, nvim 0.12+)
--
-- Parsers install via require('nvim-treesitter').install() below. Highlight
-- + indent enabled per-buffer on FileType. Folding lives in
-- config/options.lua (v:lua.vim.treesitter.foldexpr) — not here.
--
-- main branch dropped the module system. Highlight and indent are rewired
-- via vim.treesitter.start + indentexpr in a FileType autocmd. Incremental
-- selection was dropped upstream too — reimplemented below with
-- vim.treesitter.get_node (approximation of master's stack-based behavior;
-- <BS> shrinks to first named child rather than the previous selection).

return {
    {
        "nvim-treesitter/nvim-treesitter",
        branch = "main",
        lazy = false,
        build = ":TSUpdate",
        config = function()
            require("nvim-treesitter").install({
                "bash", "cpp", "diff", "fish", "gitcommit", "html",
                "http", "javascript", "kdl", "luadoc", "mermaid",
                "printf", "python", "swift", "toml", "typst", "yaml",
            })

            vim.api.nvim_create_autocmd("FileType", {
                group = vim.api.nvim_create_augroup("ts-attach", { clear = true }),
                callback = function(args)
                    local buf = args.buf
                    local lang = vim.treesitter.language.get_lang(vim.bo[buf].filetype)
                    if lang and pcall(vim.treesitter.start, buf, lang) then
                        vim.bo[buf].indentexpr = "v:lua.require'nvim-treesitter'.indentexpr()"
                    end
                end,
            })

            local function select_range(node)
                local sr, sc, er, ec = node:range()
                vim.api.nvim_win_set_cursor(0, { sr + 1, sc })
                vim.cmd("normal! v")
                vim.api.nvim_win_set_cursor(0, { er + 1, math.max(0, ec - 1) })
            end
            local function expand()
                local node = vim.treesitter.get_node()
                if not node then return end
                if vim.fn.mode():find("[vV\22]") then node = node:parent() or node end
                select_range(node)
            end
            local function shrink()
                local node = vim.treesitter.get_node()
                if not node then return end
                local child = node:named_child(0)
                if child then select_range(child) end
            end
            vim.keymap.set({ "n", "x" }, "<CR>", expand, { desc = "TS: expand selection" })
            vim.keymap.set("x", "<BS>", shrink, { desc = "TS: shrink selection" })
        end,
    },
}
