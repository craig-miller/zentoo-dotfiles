-- ~/.config/nvim/lsp/yamlls.lua
return {
    -- Explicitly point to the Mason binary path
    cmd = {
        vim.fn.stdpath("data") .. "/mason/bin/yaml-language-server",
        "--stdio"
    },
    filetypes = { "yaml", "yaml.docker-compose" },
    root_markers = { ".git", "package.json" },
    single_file_support = true,
    -- Manually enable the formatting capability
    on_init = function(client)
        client.server_capabilities.documentFormattingProvider = true
    end,
    settings = {
        yaml = {
            format = { enable = true },
            schemaStore = { enable = true },
            validate = true,
        },
    },
}
