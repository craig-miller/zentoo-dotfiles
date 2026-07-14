-- Treesitter
-- * Syntax highlighting (better and more accurate than regex-based)
-- * Indentation (context-aware, smarter than guessing based on whitespace)
-- * Code folding (based on syntax structure)
-- * Incremental selection
-- * Text objects
-- * Code navigation
return {
    {
        "nvim-treesitter/nvim-treesitter",
        branch = "master",
        build = ":TSUpdate",
        main = "nvim-treesitter.configs",
        opts = {
            ensure_installed = {
                "swift", "http", "objc", "c", "cpp", "bash",
                "lua", "luadoc", "markdown", "markdown_inline",
                "mermaid", "printf", "query", "javascript", "html",
                "toml", "typst", "vim", "vimdoc", "yaml", "python"
            },
            sync_install = false,
            auto_install = false,
            highlight = {
                enable = true,
                use_languagetree = true,
                additional_vim_regex_highlighting = { "ruby", "http" },
            },
            indent = { enable = true, disable = { "ruby" } },
            locals = { enable = true },
            incremental_selection = {
                enable = true,
                keymaps = {
                    init_selection = "<Enter>",
                    node_incremental = "<Enter>",
                    scope_incremental = false,
                    node_decremental = "<Backspace>",
                },
            },
            folding = true,
        },
    },
    {
        "nvim-treesitter/nvim-treesitter-textobjects",
        lazy = true,
        dependencies = { "nvim-treesitter/nvim-treesitter" },
    },
}
