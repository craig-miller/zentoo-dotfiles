-- Swift buffer setup, per-file:
--   • Walks up from the buffer to find Package.swift.
--   • If found, sets makeprg to `just --justfile <pkg>/justfile` so :make
--     dispatches through the project's Justfile (see :JustfileInit to
--     create one).
--   • If not found, treats the buffer as a standalone .swift file:
--     makeprg = `swiftc % -o %:r`.
--   • Sets errorformat for Swift diagnostics.
--   • Also exposes g:swift_is_package / g:swift_package_dir for nvim-dap,
--     which reads them to locate the built binary.

vim.api.nvim_create_autocmd("FileType", {
    group = vim.api.nvim_create_augroup("lang-swift", { clear = true }),
    pattern = "swift",
    callback = function()
        vim.opt_local.errorformat = "%f:%l:%c: %m"

        local pkg = vim.fn.findfile("Package.swift", vim.fn.expand("%:p:h") .. ";")
        if pkg == "" then
            vim.opt_local.makeprg = "swiftc % -o %:r"
            vim.g.swift_is_package = false
            vim.g.swift_package_dir = nil
            return
        end

        local pkg_dir = vim.fn.fnamemodify(pkg, ":p:h")
        vim.g.swift_is_package = true
        vim.g.swift_package_dir = pkg_dir

        local justfile = pkg_dir .. "/justfile"
        vim.opt_local.makeprg = "just --justfile " .. vim.fn.shellescape(justfile)
    end,
})
