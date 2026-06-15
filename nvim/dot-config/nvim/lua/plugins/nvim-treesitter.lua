-- Treesitter
-- * Syntax highlighting
-- * Syntax highlighting (better and more accurate than regex-based)
-- * Indentation (context-aware, smarter than guessing based on whitespace)
-- * Code folding (based on syntax structure, like classes, functions)
-- * Incremental selection (expand selection from token → expression → block → function → class)
-- * Text objects (targets like “select around function” or “inside loop”)
-- * Code navigation (jump between functions, classes, loops, etc.)
-- * Refactoring tools (like renaming variables with actual syntax awareness)
-- * Playground (visualize the syntax tree interactively)
-- * Querying (write tree-sitter queries to find specific patterns or nodes in your code)
return {
    {
        "nvim-treesitter/nvim-treesitter",
        build = ":TSUpdate",
        -- main = "nvim-treesitter.configs", -- Sets main module to use for opts
        -- [[ Configure Treesitter ]] See `:help nvim-treesitter`
        opts = {
            ensure_installed = {
                "swift",
                "http",
                "objc",
                "c",
                "cpp",
                "nu",
                "bash",
                "lua",
                "luadoc",
                "markdown",
                "markdown_inline",
                "latex",
                "mermaid",
                "printf",
                "query",
                "javascript",
                "html",
                "toml",
                "vim",
                "vimdoc",
                "yaml",
                -- comment,
            },
            sync_install = false,
            auto_install = true, -- Automatically install languages. Not usable offline

            highlight = {
                enable = true,
                use_languagetree = true,
                -- Some languages depend on vim's regex highlighting system (such as Ruby) for indent rules.
                --  If you are experiencing weird indenting issues, add the language to
                --  the list of additional_vim_regex_highlighting and disabled languages for indent.
                additional_vim_regex_highlighting = { "ruby", "http" },
            },
            indent = { enable = true, disable = { "ruby" } },
            locals = { enable = true, },
            incremental_selection = {
                enable = true,
                keymaps = {
                    init_selection = "<Enter>", -- set to false to disable one of the mappings
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
        lazy = true, -- Enable lazy loading for textobjects
        -- Ensure this plugin loads after nvim-treesitter if needed for configuration
        dependencies = { "nvim-treesitter/nvim-treesitter" },
    },
}
