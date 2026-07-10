-- Filetype-aware Justfile initializer. Dispatches to the corresponding
-- language module's justfile_init() helper — each language's scaffold
-- lives in ~/.config/nvim/lua/config/lang/<filetype>.lua.
vim.api.nvim_create_user_command("JustfileInit", function()
    local ft = vim.bo.filetype
    local ok, mod = pcall(require, "config.lang." .. ft)
    if not ok or type(mod) ~= "table" or not mod.justfile_init then
        vim.notify("JustfileInit: no handler for filetype " .. ft,
            vim.log.levels.WARN)
        return
    end
    mod.justfile_init()
end, {})
