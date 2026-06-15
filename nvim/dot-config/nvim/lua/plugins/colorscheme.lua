-- Using lazy.nvim
-- return {
--     "metalelf0/black-metal-theme-neovim",
--     lazy = false,
--     priority = 1000,
--     config = function()
--         require("black-metal").setup({
--             -- Can be one of: bathory | burzum | dark-funeral | darkthrone | emperor | gorgoroth | immortal | impaled-nazarene | khold | marduk | mayhem | nile | taake | thyrfing | venom | windir
--             -- theme = "bathory",
--             theme = "immortal",
--             -- Can be one of: 'light' | 'dark', or set via vim.o.background
--             variant = "dark",
--             -- Use an alternate, lighter bg
--             alt_bg = false,
--             -- If true, docstrings will be highlighted like strings, otherwise they will be
--             -- highlighted like comments. Note, behavior is dependent on the language server.
--             colored_docstrings = true,
--             -- If true, highlights the {sign,fold} column the same as cursorline
--             cursorline_gutter = true,
--             -- If true, highlights the gutter darker than the bg
--             dark_gutter = true,
--             -- if true favor treesitter highlights over semantic highlights
--             favor_treesitter_hl = false,
--             -- Don't set background of floating windows. Recommended for when using floating
--             -- windows with borders.
--             plain_float = false,
--             -- Show the end-of-buffer character
--             show_eob = true,
--             -- If true, enable the vim terminal colors
--             term_colors = true,
--             -- Keymap (in normal mode) to toggle between light and dark variants.
--             toggle_variant_key = nil,
--             -- Don't set background
--             transparent = true,
--
--             -----DIAGNOSTICS and CODE STYLE-----
--             --
--             diagnostics = {
--                 darker = true,     -- Darker colors for diagnostic
--                 undercurl = true,  -- Use undercurl for diagnostics
--                 background = true, -- Use background color for virtual text
--             },
--             -- The following table accepts values the same as the `gui` option for normal
--             -- highlights. For example, `bold`, `italic`, `underline`, `none`.
--             code_style = {
--                 comments = "italic",
--                 conditionals = "none",
--                 functions = "none",
--                 keywords = "none",
--                 headings = "bold", -- Markdown headings
--                 operators = "none",
--                 keyword_return = "none",
--                 strings = "none",
--                 variables = "none",
--             },
--             -----PLUGINS-----
--             --
--             -- The following options allow for more control over some plugin appearances.
--             plugin = {
--                 lualine = {
--                     -- Bold lualine_a sections
--                     bold = true,
--                     -- Don't set section/component backgrounds. Recommended to not set
--                     -- section/component separators.
--                     plain = false,
--                 },
--                 cmp = { -- works for nvim.cmp and blink.nvim
--                     -- Don't highlight lsp-kind items. Only the current selection will be highlighted.
--                     plain = false,
--                     -- Reverse lsp-kind items' highlights in blink/cmp menu.
--                     reverse = false,
--                 },
--             },
--
--             -- CUSTOM HIGHLIGHTS --
--             --
--             -- Override default colors
--             colors = {},
--             -- Override highlight groups
--             highlights = {},
--
--         })
--         require("black-metal").load()
--     end,
--
--
-- }
--
return {
    "catppuccin/nvim",
    name = "catppuccin",
    priority = 1000,
    opts = {

        flavour = "mocha", -- latte, frappe, macchiato, mocha
        background = {     -- :h background
            light = "latte",
            dark = "mocha",
        },
        transparent_background = true, -- disables setting the background color.
        show_end_of_buffer = false,     -- shows the '~' characters after the end of buffers
        term_colors = false,            -- sets terminal colors (e.g. `g:terminal_color_0`)
        dim_inactive = {
            enabled = false,            -- dims the background color of inactive window
            shade = "dark",
            percentage = 0.15,          -- percentage of the shade to apply to the inactive window
        },
        no_italic = false,              -- Force no italic
        no_bold = false,                -- Force no bold
        no_underline = false,           -- Force no underline
        styles = {                      -- Handles the styles of general hi groups (see `:h highlight-args`):
            -- comments = { "italic" }, -- Change the style of comments
            conditionals = { "italic" },
            loops = {},
            functions = {},
            keywords = {},
            strings = {},
            variables = {},
            numbers = {},
            booleans = {},
            properties = {},
            types = {},
            operators = {},
            -- miscs = {}, -- Uncomment to turn off hard-coded styles
        },
        color_overrides = {},
        custom_highlights = {},
        default_integrations = true,
        integrations = {
            blink_cmp = true,
            cmp = true,
            gitsigns = true,
            nvimtree = true,
            treesitter = true,
            notify = true,
            fzf = true,
            mini = {
                enabled = true,
                indentscope_color = "",
            },
            lualine = true,
            mason = true,
            neotest = true,
            dap = true,
            dap_ui = true,

            -- For more plugins integrations please scroll down (https://github.com/catppuccin/nvim#integrations)
        },
    },
    config = function(_, opts)
        require("catppuccin").setup(opts)
        vim.cmd.colorscheme("catppuccin-mocha")
    end,
}
