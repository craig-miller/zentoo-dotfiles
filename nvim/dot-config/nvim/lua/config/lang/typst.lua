-- Typst buffer setup.
-- FileType autocmd:
--   - Sets makeprg = "typst compile %" so a bare :make compiles the
--     current buffer into quickfix. Useful for CI-style one-shot builds;
--     for authoring, use the live preview via <leader>tp.
--   - Registers buffer-local <leader>tp → :TypstPreviewToggle (provided
--     by chomosuke/typst-preview.nvim). Sits under the "Toggle" group in
--     which-key. Typst does not participate in the swift/just <leader>m
--     submap.

vim.api.nvim_create_autocmd("FileType", {
    group = vim.api.nvim_create_augroup("lang-typst", { clear = true }),
    pattern = "typst",
    callback = function()
        vim.opt_local.errorformat = " %#┌─ %f:%l:%c,%trror: %m,%tarning: %m,%-G%.%#"
        vim.opt_local.makeprg = "typst compile %"

        vim.keymap.set("n", "<leader>tp", "<Cmd>TypstPreviewToggle<CR>",
            { buffer = 0, silent = true, desc = "Toggle Preview" })
    end,
})
