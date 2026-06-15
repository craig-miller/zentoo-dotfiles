local function get_sourcekit_lsp_cmd()
    local home = os.getenv("HOME")
    local swiftly_path = home .. "/.swiftly/bin/sourcekit-lsp"

    if vim.fn.executable(swiftly_path) == 1 then
        -- print("SWIFTLY: " .. swiftly_path)
        return { swiftly_path }
    end

    if jit.os == "OSX" then
        local xcrun_path = vim.fn.trim(vim.fn.system("xcrun --find sourcekit-lsp"))
        if xcrun_path ~= "" then
            print("XCRUN: " .. xcrun_path)
            return { xcrun_path }
        end
    end

    print("FALLBACK: sourcekit-lsp")
    return { "sourcekit-lsp" }
end

return {
    cmd = get_sourcekit_lsp_cmd(),
    filetypes = { "swift", "objective-c", "objective-cpp" },
    root_markers = {
        "*.xcodeproj",
        "Package.swift",
        "buildserver.json",
        ".swift-version",
        ".git",
    },
    capabilities = {
        workspace = {
            didChangeWatchedFiles = {
                dynamicRegistration = true,
                interFileDependencies = true,
                workspaceDiagnostics = true,
            },
        },
    },
    -- This cause duplicate error message reporting.
    -- TODO:  What is the on_init function intended for?
    -- on_init = function(client)
    --     client.server_capabilities.diagnosticProvider = {
    --         interFileDependencies = false,
    --         workspaceDiagnostics = false,
    --     }
    --     if client.name == "sourcekit" then
    --         vim.lsp.handlers["textDocument/publishDiagnostics"] = function() end
    --     end
    -- end,
}
