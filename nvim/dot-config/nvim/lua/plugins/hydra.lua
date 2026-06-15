return {
    "nvimtools/hydra.nvim",
    keys = {
        { "<leader>w", desc = "Window mode" },
    },
    config = function()
        local Hydra = require("hydra")
        local colors = require("catppuccin.palettes").get_palette()

        -- Override Hydra's built-in highlight groups with Catppuccin colors
        vim.api.nvim_set_hl(0, "HydraPink", { fg = colors.blue, bold = true })
        vim.api.nvim_set_hl(0, "HydraRed", { fg = colors.green, bold = true })
        vim.api.nvim_set_hl(0, "HydraHint", { link = "NormalFloat" })
        vim.api.nvim_set_hl(0, "HydraBorder", { link = "FloatBorder" })

        -- Nerd font icons (using literal chars via shell write)
        Hydra({
            name = "Window",
            hint = [[
              󰖯 Window Mode

   Move         Resize       Other

   _h_: 󰁍 left    _H_: 󰮹 left    _s_:  horiz
   _j_: 󰁅 down    _J_: 󰮷 down    _v_:  vert
   _k_: 󰁝 up      _K_: 󰮽 up      _m_: 󰁌 maximize
   _l_: 󰁔 right   _L_: 󰮺 right   _x_: 󰅖 close

   _=_: equal size  _n_: next layout
]],
            mode = "n",
            body = "<leader>w",
            config = {
                hint = {
                    type = "window",
                    position = "middle",
                    float_opts = {
                        border = "rounded",
                    },
                },
                invoke_on_body = true,
                color = "pink",
                on_enter = function()
                    vim.o.laststatus = 3
                end,
            },
            heads = {
                -- Move splits
                { "h",     "<C-w>H",                     { desc = "Move left" } },
                { "j",     "<C-w>J",                     { desc = "Move down" } },
                { "k",     "<C-w>K",                     { desc = "Move up" } },
                { "l",     "<C-w>L",                     { desc = "Move right" } },

                -- Resize splits
                { "H",     ":vertical resize -5<CR>",    { desc = "Resize left" } },
                { "J",     ":resize -5<CR>",             { desc = "Resize down" } },
                { "K",     ":resize +5<CR>",             { desc = "Resize up" } },
                { "L",     ":vertical resize +5<CR>",    { desc = "Resize right" } },

                -- Split
                { "s",     "<C-w>s",                     { desc = "Split horizontal" } },
                { "v",     "<C-w>v",                     { desc = "Split vertical" } },

                -- Maximize / Close
                { "m",     ":MaximizerToggle<CR>",       { desc = "Maximize", exit = true } },
                { "x",     "<C-w>c",                     { desc = "Close", exit = true } },

                -- Layout
                { "=",     "<C-w>=",                     { desc = "Equal size" } },
                { "n",     ":wincmd w<CR>:wincmd L<CR>", { desc = "Next layout" } },

                { "<Esc>", nil,                          { exit = true, nowait = true, desc = "Quit" } },
            },
        })
    end,
}
