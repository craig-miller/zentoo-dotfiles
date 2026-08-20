-- https://github.com/nvim-telescope/telescope.nvim
-- Telescope is the primary picker. telescope-fzf-native is the compiled sorter
-- that makes it competitive with fzf-lua on large repos — required, not optional.
return {
    "nvim-telescope/telescope.nvim",
    branch = "0.1.x",
    priority = 1000,
    lazy = false,
    dependencies = {
        "nvim-lua/plenary.nvim",
        "nvim-mini/mini.icons",
        {
            "nvim-telescope/telescope-fzf-native.nvim",
            build = "make",
        },
    },
    config = function()
        local telescope = require("telescope")
        local actions = require("telescope.actions")
        telescope.setup({
            defaults = {
                -- Follow symlinks: many dotfiles ($HOME, ~/.config/*) are
                -- Stow-managed symlinks into ~/dotfiles/ that rg skips by default.
                vimgrep_arguments = {
                    "rg", "--color=never", "--no-heading",
                    "--with-filename", "--line-number", "--column",
                    "--smart-case", "--follow",
                },
                file_ignore_patterns = {
                    "Assets",
                    "node_modules",
                    "dist",
                    "%.next",
                    "%.git/",
                    "%.jj/",
                    "%.gitlab",
                    "build/",
                    "Build/",
                    "target/",
                    "package%-lock%.json",
                    "pnpm%-lock%.yaml",
                    "yarn%.lock",
                },
                mappings = {
                    i = {
                        ["<C-a>"] = actions.select_all,
                        ["<esc>"] = actions.close,
                    },
                },
            },
            pickers = {
                find_files = {
                    find_command = {
                        "rg", "--color=never", "--files", "--follow",
                        "-g", "!.git", "-g", "!.jj",
                    },
                },
            },
            extensions = {
                fzf = {
                    fuzzy = true,
                    override_generic_sorter = true,
                    override_file_sorter = true,
                    case_mode = "smart_case",
                },
            },
        })
        telescope.load_extension("fzf")

        -- nvim-treesitter main-branch API gap. Telescope call sites do
        -- `pcall(require, "nvim-treesitter.parsers")` — that succeeds on
        -- main (the top-level module still exists), then call `.ft_to_lang`
        -- or `configs.is_enabled` which main dropped, and error out.
        -- Stub both at the source so every telescope path benefits
        -- (current_buffer_fuzzy_find in builtin/__files.lua is one such
        -- path — throws on ft_to_lang without this).
        local parsers_ok, parsers = pcall(require, "nvim-treesitter.parsers")
        if parsers_ok and not parsers.ft_to_lang then
            parsers.ft_to_lang = function(ft)
                return vim.treesitter.language.get_lang(ft) or ft
            end
        end
        -- nvim-treesitter.configs is entirely absent on main (not just
        -- API-changed like parsers is), so pcall-require FAILS and any
        -- guard that keys off configs_ok never fires. Inject a fake module
        -- into package.loaded so telescope's later pcall(require, ...) call
        -- returns our stub instead of failing and leaving the caller with
        -- an error-string that indexes to nil.
        if not package.loaded["nvim-treesitter.configs"] then
            package.loaded["nvim-treesitter.configs"] = {
                is_enabled = function(_, _, _) return true end,
            }
        end

        -- Preview TS attach shim. Complements the source-level stubs above:
        -- the previewer's ts_highlighter body uses master-branch APIs in a
        -- shape the stubs alone can't fix (it also depends on parser +
        -- query wiring). Replace with built-in vim.treesitter APIs.
        local putils = require("telescope.previewers.utils")
        putils.ts_highlighter = function(bufnr, ft)
            local lang = vim.treesitter.language.get_lang(ft)
            if not lang then return false end
            local ok = pcall(vim.treesitter.language.add, lang)
            if not ok then return false end
            return pcall(vim.treesitter.start, bufnr, lang)
        end
    end,
    keys = {
        -- Group label for which-key
        { "<leader>f", desc = "Find" },

        -- Find files in cwd
        {
            "<leader>ff",
            function()
                vim.cmd("normal! m'")
                require("telescope.builtin").find_files()
            end,
            desc = "[F]ind [F]iles in cwd",
        },

        -- Live grep in project
        {
            "<leader>fg",
            function() require("telescope.builtin").live_grep() end,
            desc = "Grep Files",
        },

        -- Recent files
        {
            "<leader>fr",
            function() require("telescope.builtin").oldfiles() end,
            desc = "[F]ind [R]ecent",
        },

        -- Grep for word under cursor
        {
            "<leader>fw",
            function() require("telescope.builtin").grep_string() end,
            desc = "[F]ind [W]ord",
        },

        -- Find in nvim config
        -- Point at the real path (~/dotfiles/nvim/dot-config/nvim), not the
        -- Stow-symlinked ~/.config/nvim, so buffer paths land inside the git
        -- repo and gitsigns / :Git etc. work correctly.
        {
            "<leader>fc",
            function()
                require("telescope.builtin").find_files({
                    cwd = vim.fn.expand("~/dotfiles/nvim/dot-config/nvim"),
                })
            end,
            desc = "[F]ind [C]onfig",
        },

        {
            "<leader>fb",
            function() require("telescope.builtin").buffers() end,
            desc = "Find Buffer",
        },

        {
            "<leader>fh",
            function() require("telescope.builtin").help_tags() end,
            desc = "Find Help",
        },

        {
            "<leader>fk",
            function() require("telescope.builtin").keymaps() end,
            desc = "Find Keymap",
        },

        {
            "<leader>fz",
            function() require("telescope.builtin").builtin() end,
            desc = "Telescope pickers",
        },

        {
            "<leader>tw",
            function() require("telescope.builtin").diagnostics() end,
            desc = "[T]oggle [W]orkspace diagnostics",
        },
    },
}
