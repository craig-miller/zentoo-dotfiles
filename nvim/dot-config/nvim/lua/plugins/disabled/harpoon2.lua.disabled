return {
    "ThePrimeagen/harpoon",
    branch = "harpoon2",
    opts = {
        menu = {
            width = vim.api.nvim_win_get_width(0) - 4,
        },
        settings = {
            save_on_toggle = true,
        },
    },
    keys = function()
        local toggle_opts = {
            border = "rounded",
            title_pos = "center",
            ui_width_ratio = 0.40,
            title = " Harpoon "
        }


        local keys = {
            {
                "<leader>a",
                function()
                    require("harpoon"):list():add()
                end,
                desc = "Add File",
            },
            {
                "<leader>r",
                function()
                    require("harpoon"):list():remove()
                end,
                desc = "Remove File",
            },
            {
                "<leader>h",
                function()
                    local harpoon = require("harpoon")
                    harpoon.ui:toggle_quick_menu(harpoon:list(), toggle_opts)
                end,
                desc = "Harpoon Quick Menu",
            },
        }

        for i = 1, 9 do
            table.insert(keys, {
                "<leader>" .. i,
                function()
                    require("harpoon"):list():select(i)
                end,
                desc = "Go to File " .. i,
            })
        end
        return keys
    end,
}
