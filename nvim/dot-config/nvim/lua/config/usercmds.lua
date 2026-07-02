-- Create a `justfile` in the current buffer's Swift PM project root with
-- the standard target set expected by our <leader>m* keybinds. Walks up
-- from the current buffer looking for Package.swift; refuses to run
-- outside a Swift PM project or clobber an existing justfile.
vim.api.nvim_create_user_command("JustfileInit", function()
    local pkg = vim.fn.findfile("Package.swift", vim.fn.expand("%:p:h") .. ";")
    if pkg == "" then
        vim.notify("JustfileInit: no Package.swift found above this buffer",
            vim.log.levels.WARN)
        return
    end
    local pkg_dir = vim.fn.fnamemodify(pkg, ":p:h")
    local justfile = pkg_dir .. "/justfile"

    if vim.fn.filereadable(justfile) == 1 then
        vim.notify("JustfileInit: justfile already exists at " .. justfile,
            vim.log.levels.INFO)
        return
    end

    vim.fn.writefile({
        "debug:",
        "    swift build -c debug",
        "",
        "release:",
        "    swift build -c release",
        "",
        "run-debug:",
        "    swift run -c debug",
        "",
        "run-release:",
        "    swift run -c release",
        "",
        "test:",
        "    swift test",
        "",
        "clean:",
        "    swift package clean",
    }, justfile)
    vim.notify("JustfileInit: created " .. justfile, vim.log.levels.INFO)
end, {})
