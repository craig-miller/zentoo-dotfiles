local function nonempty(value)
    return value ~= nil and value ~= ""
end

local function xcodebuild_has_status()
    return nonempty(vim.g.xcodebuild_last_status)
end

local function xcodebuild_has_test_plan()
    return nonempty(vim.g.xcodebuild_test_plan)
end

local function xcodebuild_has_device()
    return nonempty(vim.g.xcodebuild_platform) and nonempty(vim.g.xcodebuild_device_name)
end

local function xcodebuild_device()
    if vim.g.xcodebuild_platform == "macOS" then
        return " macOS"
    end

    local deviceIcon = ""
    if vim.g.xcodebuild_platform:match("watch") then
        deviceIcon = "􀟤"
    elseif vim.g.xcodebuild_platform:match("tv") then
        deviceIcon = "􀡴 "
    elseif vim.g.xcodebuild_platform:match("vision") then
        deviceIcon = "􁎖 "
    end

    if vim.g.xcodebuild_os then
        return deviceIcon .. " " .. vim.g.xcodebuild_device_name .. " (" .. vim.g.xcodebuild_os .. ")"
    end

    return deviceIcon .. " " .. vim.g.xcodebuild_device_name
end
return {
    "nvim-lualine/lualine.nvim",
    lazy = false,
    dependencies = {
        { "yavorski/lualine-macro-recording.nvim" },
        { "nvim-tree/nvim-web-devicons" },
    },
    options = {
        theme = "catpuccin",
    },
    config = function()
        local transparent_groups = {
            "lualine_c_normal", "lualine_c_insert", "lualine_c_visual",
            "lualine_c_replace", "lualine_c_command", "lualine_c_terminal",
            "lualine_c_inactive",
            "lualine_x_normal", "lualine_x_insert", "lualine_x_visual",
            "lualine_x_replace", "lualine_x_command", "lualine_x_terminal",
            "lualine_x_inactive",
        }
        local function clear_pill_bg()
            local lualine_hl = require("lualine.highlight")
            for _, name in ipairs(transparent_groups) do
                local hl = vim.api.nvim_get_hl(0, { name = name })
                local fg = hl.fg and string.format("#%06x", hl.fg) or nil
                local gui_parts = {}
                if hl.bold then table.insert(gui_parts, "bold") end
                if hl.italic then table.insert(gui_parts, "italic") end
                if hl.underline then table.insert(gui_parts, "underline") end
                lualine_hl.highlight(name, fg, "NONE", table.concat(gui_parts, ","), nil)
            end
        end
        vim.api.nvim_create_autocmd("ColorScheme", {
            group = vim.api.nvim_create_augroup("LualinePillTransparency", { clear = true }),
            callback = function()
                vim.schedule(clear_pill_bg)
            end,
        })

        require("lualine").setup({
            options = {
                theme = "auto",
                component_separators = "",
                section_separators = { left = "", right = "" },
            },
            sections = {
                lualine_a = { { "mode", separator = { left = "" }, right_padding = 2 } },
                -- lualine_b = { "filename", "branch" },
                lualine_b = { "filename", "branch" },
                lualine_c = {
                    { "%=", color = { bg = "NONE" } },
                    --[[ add your center components here in place of this comment ]]
                    { "diagnostics", color = { bg = "NONE" } },
                    { "macro_recording", color = { bg = "NONE" } },
                    { "%S", color = { bg = "NONE" } },
                },
                lualine_x = {},
                -- lualine_y = { "filetype", "progress", "require'lsp-status'.status()" },
                lualine_y = {
                    {
                        "' ' .. vim.g.xcodebuild_last_status",
                        color = { fg = "Gray" },
                        cond = xcodebuild_has_status,
                    },
                    {
                        "'󰙨 ' .. vim.g.xcodebuild_test_plan",
                        color = { fg = "#a6e3a1" },
                        cond = xcodebuild_has_test_plan,
                    },
                    {
                        xcodebuild_device,
                        color = { fg = "#f9e2af" },
                        cond = xcodebuild_has_device,
                    },
                    "filetype",
                    "lsp-status",
                },
                lualine_z = {
                    { "location", separator = { right = "" }, left_padding = 2 },
                },
            },
            inactive_sections = {
                lualine_a = { "filename" },
                lualine_b = {},
                lualine_c = {},
                lualine_x = {},
                lualine_y = {},
                lualine_z = { "location" },
            },
            tabline = {},
            extensions = {},
        })

        clear_pill_bg()
    end,
}
