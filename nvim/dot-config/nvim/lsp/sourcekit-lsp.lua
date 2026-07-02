return {
    cmd = { "sourcekit-lsp" },
    filetypes = { "swift" },
    root_markers = {
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
}
