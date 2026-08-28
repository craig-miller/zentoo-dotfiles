-- Catppuccin with palette overrides driven by noctalia.
--
-- Noctalia renders ~/.cache/noctalia/nvim-palette.lua on every wallpaper
-- change (M3 tonal-spot -> catppuccin-named palette table), then the
-- template post_hook fires SIGUSR1 -x nvim.  The handler here re-reads
-- that table via loadfile (no require cache), feeds it to
-- catppuccin.color_overrides.mocha, and re-applies the colorscheme.
--
-- First boot before noctalia has rendered: falls back to stock mocha.

local function load_palette()
    local chunk = loadfile(vim.fn.expand("~/.cache/noctalia/nvim-palette.lua"))
    return chunk and chunk() or nil
end

local function apply()
    local palette = load_palette()
    require("catppuccin").setup({
        flavour = "mocha",
        background = { light = "latte", dark = "mocha" },
        transparent_background = true,
        show_end_of_buffer = false,
        term_colors = false,
        dim_inactive = { enabled = false },
        styles = {
            conditionals = { "italic" },
        },
        color_overrides = palette and { mocha = palette } or {},
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
    })
    vim.cmd.colorscheme("catppuccin-mocha")
end

return {
    {
        "catppuccin/nvim",
        name = "catppuccin",
        priority = 1000,
        lazy = false,
        config = function()
            apply()
            local signal = vim.uv.new_signal()
            signal:start("sigusr1", vim.schedule_wrap(apply))
        end,
    },

    -- Inline color previews for #RRGGBB, rgb(), hsl(), ansi, CSS vars,
    -- named colors.  Not tied to the active colorscheme.
    {
        "brenoprata10/nvim-highlight-colors",
        opts = {
            -- Show color previews as virtual text so the source text
            -- remains readable and its background is not changed.
            render = "virtual",
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
