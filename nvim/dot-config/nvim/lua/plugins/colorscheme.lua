-- Colorschemes + color-related plugins, in one file.
--
--   catppuccin        — primary theme (mocha), sets :colorscheme on load.
--   base16-nvim       — fallback for tinty schemes without dedicated plugins;
--                       driven by `:colorscheme base16-<slug>` from the
--                       external switcher (~/.config/tinted-theming/extras/
--                       nvim-rpc.sh via the per-PID socket in init.lua).
--   nvim-highlight-colors — inline #RRGGBB / rgb() / hsl() previews.
--
-- Cross-plugin highlight overrides that need to survive theme swaps belong
-- in a ColorScheme autocmd, not scattered across plugin configs. (Not yet
-- migrated here — hydra.lua and matugen.lua still set their own hi groups.)

return {
    {
        "catppuccin/nvim",
        name = "catppuccin",
        priority = 1000,
        opts = {
            flavour = "mocha",
            background = { light = "latte", dark = "mocha" },
            transparent_background = true,
            show_end_of_buffer = false,
            term_colors = false,
            dim_inactive = { enabled = false, shade = "dark", percentage = 0.15 },
            no_italic = false,
            no_bold = false,
            no_underline = false,
            styles = {
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
                mini = { enabled = true, indentscope_color = "" },
                lualine = true,
                mason = true,
                neotest = true,
                dap = true,
                dap_ui = true,
            },
        },
        config = function(_, opts)
            require("catppuccin").setup(opts)
            vim.cmd.colorscheme("catppuccin-mocha")
        end,
    },

    -- Fallback for tinty schemes without a dedicated plugin (e.g. Twilight).
    -- RRethy/base16-nvim reads the active scheme via base16-vim's API; the
    -- external switcher drives it with `:colorscheme base16-<slug>`.
    {
        "RRethy/base16-nvim",
        lazy = true,
        priority = 1000,
    },

    -- Inline color previews for #RRGGBB, rgb(), hsl(), ansi, CSS vars,
    -- named colors. Not tied to the active colorscheme.
    {
        "brenoprata10/nvim-highlight-colors",
        opts = {
            render = "foreground, virtual",
            virtual_symbol = "■",
            virtual_symbol_prefix = "",
            virtual_symbol_suffix = " ",
            virtual_symbol_position = "inline",
            enable_hex = true,
            enable_short_hex = true,
            enable_rgb = true,
            enable_hsl = true,
            enable_ansi = true,
            enable_hsl_without_function = true,
            enable_var_usage = true,
            enable_named_colors = true,
            enable_tailwind = false,
            exclude_buffer = function(bufnr) end,
        },
    },
}
