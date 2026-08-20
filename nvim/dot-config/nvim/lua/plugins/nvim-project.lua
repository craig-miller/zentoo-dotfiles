return {
    "coffebar/neovim-project",
    opts = {
        projects = { -- define project roots
            "~/src/*",
            "~/docs/*",
            "~/research/pubs/",
            "~/.config/*",
        },
        picker = {
            type = "telescope",      -- one of "telescope", "fzf-lua", or "snacks"
            preview = {
                enabled = false,     -- show directory structure in Telescope preview
                git_status = true,   -- show branch name, an ahead/behind counter, and the git status of each file/folder
                git_fetch = true,    -- fetch from remote, used to display the number of commits ahead/behind, requires git authorization
                show_hidden = false, -- show hidden files/folders
            },
            opts = {
                -- picker-specific options
            },
        },
        cd_type = "global",
        last_session_on_startup = false,
        dashboard = true,
    },
    init = function()
        -- enable saving the state of plugins in the session
        vim.opt.sessionoptions:append("globals") -- save global variables that start with an uppercase letter and contain at least one lowercase letter.
    end,
    dependencies = {
        { "nvim-lua/plenary.nvim" },
        { "nvim-telescope/telescope.nvim" },
        { "Shatur/neovim-session-manager" },
    },
    keys = {
        -- Project Management: Ctrl+d in the picker deletes project session history.
        { "<leader>fp", "<CMD>NeovimProjectDiscover<CR>", desc = "Find Project", mode = { "n" } },
        -- { "<leader>fpr", "<CMD>NeovimProjectHistory<CR>",    desc = "Recent",       mode = { "n" } },
        -- { "<leader>fpl", "<CMD>NeovimProjectLoadRecent<CR>", desc = "Last Session", mode = { "n" } },
    },
    lazy = false,
    priority = 100,
}
