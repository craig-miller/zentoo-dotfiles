return {
    "saghen/blink.cmp",
    -- use a release tag to download pre-built binaries
    version = "1.*",
    dependencies = {
        "Kaiser-Yang/blink-cmp-git",
        -- optional: provides snippets for the snippet source
        -- "rafamadriz/friendly-snippets",
        "nvim-lua/plenary.nvim",
        -- "ribru17/blink-cmp-spell",
        -- "MeanderingProgrammer/render-markdown.nvim",
    },
    init = function()
        -- Remove global capability setting - now handled per-server in lsp.lua
        -- if vim.fn.has("nvim-0.11") == 1 and vim.lsp.config then
        --     vim.lsp.config("*", {
        --         capabilities = require("blink.cmp").get_lsp_capabilities(),
        --     })
        -- end
    end,

    opts = {
        -- 'default' (recommended) for mappings similar to built-in completions (C-y to accept)
        -- 'super-tab' for mappings similar to vscode (tab to accept)
        -- 'enter' for enter to accept
        -- 'none' for no mappings
        --
        -- All presets have the following mappings:
        -- C-space: Open menu or open docs if already open
        -- C-n/C-p or Up/Down: Select next/previous item
        -- C-e: Hide menu
        -- C-k: Toggle signature help (if signature.enabled = true)
        --
        -- See :h blink-cmp-config-keymap for defining your own keymap
        -- keymap = { preset = "default" },
        keymap = {

            -- preset = "default",
            preset = "super-tab",
            -- ["<C-j>"] = { "select_next", "fallback" },  -- down
            -- ["<Down>"] = { "select_next", "fallback" }, -- down
            --
            -- ["<C-k>"] = { "select_prev", "fallback" },  -- up
            -- ["<Up>"] = { "select_prev", "fallback" },   -- up
            --
            -- ["<Tab>"] = { "accept" },                   -- Accept currently selected completion
            -- ["<C-space>"] = { "show" },                 -- Manually trigger completion
            -- ["<CR>"] = { "fallback" },                  -- fallback means it will fallthrough to normal enter
        },
        -- snippets = { preset = "luasnip" },
        signature = { enabled = true },
        appearance = {
            use_nvim_cmp_as_default = false,
            -- 'mono' (default) for 'Nerd Font Mono' or 'normal' for 'Nerd Font'
            -- Adjusts spacing to ensure icons are aligned
            nerd_font_variant = "mono",
        },

        -- (Default) Only show the documentation popup when manually triggered
        -- We want to auto-show the documentation
        completion = {
            menu = {
                border = "rounded",
                scrolloff = 1,
                scrollbar = false,
            },
            ghost_text = {
                enabled = true,
            },
            documentation = {
                auto_show = true,
            },
        },

        -- Default list of enabled providers defined so that you can extend it
        -- elsewhere in your config, without redefining it, due to `opts_extend`
        sources = {
            default = { "snippets", "lsp", "buffer", "omni", "lazydev", "path" },
            -- lsp, path, snippets, luasnip, buffer, and omni
            -- default = { "lsp", "path", "snippets", "git", "spell" },
            -- default = { "lsp", "buffer", "snippets", "path", "git" },
            per_filetype = {
                markdown = { "papis", "lsp", "path", "buffer", "git", "spell" },
                typst    = { "papis", "lsp", "path", "buffer", "git" },
                yaml     = { "papis", "lsp", "path", "buffer" },
            },
            providers = {
                -- dadbod = { name = "Dadbod", module = "vim_dadbod_completion.blink" },
                lazydev = {
                    name = "LazyDev",
                    module = "lazydev.integrations.blink",
                    -- make lazydev completions top priority (see `:h blink.cmp`)
                    score_offset = 100,
                },
                git = {
                    module = "blink-cmp-git",
                    name = "Git",
                    score_offset = 15,
                    opts = {
                        -- options for the blink-cmp-git
                        commit = {
                            -- You may want to customize when it should be enabled
                            -- The default will enable this when `git` is found and `cwd` is in a git repository
                            --enable = function() end,
                            -- You may want to change the triggers
                            --triggers = { ":" },
                        },
                        git_centers = {
                            github = {
                                -- Those below have the same fields with `commit`
                                -- Those features will be enabled when `git` and `gh` (or `curl`) are found and
                                -- remote contains `github.com`
                                -- issue = {
                                --     get_token = function() return '' end,
                                -- },
                                -- pull_request = {
                                --     get_token = function() return '' end,
                                -- },
                                -- mention = {
                                --     get_token = function() return '' end,
                                --     get_documentation = function(item)
                                --         local default = require('blink-cmp-git.default.github')
                                --             .mention.get_documentation(item)
                                --         default.get_token = function() return '' end
                                --         return default
                                --     end
                                -- }
                            },
                        },
                    },
                    should_show_items = function()
                        return vim.tbl_contains({ "gitcommit" }, vim.o.filetype)
                    end,
                },
            },
        },

        -- (Default) Rust fuzzy matcher for typo resistance and significantly better performance
        -- You may use a lua implementation instead by using `implementation = "lua"` or fallback to the lua implementation,
        -- when the Rust fuzzy matcher is not available, by using `implementation = "prefer_rust"`
        --
        -- See the fuzzy documentation for more information
        -- fuzzy = { implementation = "prefer_rust_with_warning" },
    },
    opts_extend = { "sources.default" },
}
