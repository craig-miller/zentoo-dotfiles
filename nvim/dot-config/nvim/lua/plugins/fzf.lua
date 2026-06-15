-- https://github.com/ibhagwan/fzf-lua
-- This is a fuzzy picker.  It includes a bunch of it's own builtin functionality like files,
return {
    "ibhagwan/fzf-lua",
    dependencies = { "nvim-mini/mini.icons" },
    opts = {
        file_icons = "mini",
        fzf_colors = {
            true, -- inherit fzf colors that aren't specified below from
            --     -- the auto-generated theme similar to `fzf_colors=true`
            --     -- ["fg"]          = { "fg", "CursorLine" },
            --     -- ["bg"] = { "bg", "None" },
            -- ["bg"]     = { "bg", "-1" }, -- Set background to transparent
            --     -- ["hl"]          = { "fg", "Comment" },
            --     -- ["fg+"]         = { "fg", "Normal", "underline" },
            -- ["bg+"]         = { "bg", { "CursorLine", "Normal" } },
            -- ["hl+"]         = { "fg", "Statement" },
            --     -- ["info"]        = { "fg", "PreProc" },
            --     -- ["prompt"]      = { "fg", "Conditional" },
            --     -- ["pointer"]     = { "fg", "Exception" },
            --     -- ["marker"]      = { "fg", "Keyword" },
            --     -- ["spinner"]     = { "fg", "Label" },
            --     -- ["header"]      = { "fg", "Comment" },
            -- ["gutter"] = "-1",
            -- ["border"] = "-1",
        },
        file_ignore_patterns = {
            "Assets",
            "node_modules",
            "dist",
            ".next",
            ".git",
            ".gitlab",
            "build",
            "Build",
            "target",
            "package-lock.json",
            "pnpm-lock.yaml",
            "yarn.lock",
        },
        fzf = {
            ["ctrl-a"] = "select-all+accept",
        }
    },
    keys = {
        -- For which-key presentation
        {
            "<leader>f",
            desc = "Find",
        },

        -- Find in current buffer
        {
            "<leader><leader>",
            function()
                require("fzf-lua").lgrep_curbuf()
            end,
            desc = "Find .",
        },

        -- Find in files
        {
            "<leader>ff",
            function()
                -- Add current position to the jump list
                vim.cmd("normal! m'")
                -- Select and open another file.
                require("fzf-lua").files()
            end,
            desc = "[F]ind [F]iles in cwd",
        },

        -- Grep in project
        {
            "<leader>fg",
            function()
                require("fzf-lua").live_grep()
            end,
            desc = "Grep Files",
        },

        -- Find Recent
        {
            "<leader>fr",
            function()
                require("fzf-lua").oldfiles()
            end,
            desc = "[F]ind [R]ecent",
        },

        -- Find word under cursor
        {
            "<leader>fw",
            function()
                require("fzf-lua").grep_cword()
            end,
            desc = "[F]ind [W]ord",
        },

        -- Find a config file
        {
            "<leader>fc",
            function()
                require("fzf-lua").files({ cwd = vim.fn.stdpath("config") })
            end,
            desc = "[F]ind [C]onfig",
        },

        -- Find a note in my Notes directory
        {
            "<leader>fn",
            function()
                require("fzf-lua").files({
                    cwd = "~/Notes",
                    fd_opts = "--type f --exclude '.*'",
                })
            end,
            desc = "[F]ind [N]ote",
        },

        {
            "<leader>fb",
            function()
                require("fzf-lua").buffers()
            end,
            desc = "Find Buffer",
        },
        -- Broken

        {
            "<leader>fh",
            function()
                require("fzf-lua").helptags()
            end,
            desc = "Find Help",
        },

        {
            "<leader>fk",
            function()
                require("fzf-lua").keymaps()
            end,
            desc = "Find Keymap",
        },
        {
            "<leader>fz",
            function()
                require("fzf-lua").builtin()
            end,
            desc = "Fzf fuzzy finder",
        },
        {
            "<leader>sw",
            function()
                require("fzf-lua").diagnostics_workspace()
            end,
            desc = "[S]how [W]orkspace quickfix list",
        },
    },
}
