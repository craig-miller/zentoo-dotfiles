-- 1. Setup Mason first
require("mason").setup()

-- 2. Optional: Add Mason's bin to Neovim's PATH
-- This allows you to just use 'yaml-language-server' in cmd
local mason_bin = vim.fn.stdpath("data") .. "/mason/bin"
vim.env.PATH = mason_bin .. ":" .. vim.env.PATH

-- Configure LSP servers
vim.lsp.enable({
    "lua_ls",
    "sourcekit-lsp",
    "yamlls",
    -- "bibli_ls"
})

-- Load and apply markdown-oxide configuration
local markdown_oxide_config = dofile(vim.fn.stdpath("config") .. "/lsp/markdown-oxide.lua")
vim.lsp.config("markdown_oxide", markdown_oxide_config)
vim.lsp.enable("markdown_oxide")

vim.diagnostic.config({
    severity_sort = true,
    update_in_insert = false,
    float = { border = "rounded", source = "if_many" },
    -- float = { border = "rounded", source = "true" },
    -- float = false,
    -- underline = { severity = vim.diagnostic.severity.ERROR },
    underline = false,
    signs = vim.g.have_nerd_font and {
        text = {
            [vim.diagnostic.severity.ERROR] = "󰅚 ",
            [vim.diagnostic.severity.WARN] = "󰀪 ",
            [vim.diagnostic.severity.INFO] = "󰋽 ",
            [vim.diagnostic.severity.HINT] = "󰌶 ",
        },
        numhl = {
            [vim.diagnostic.severity.ERROR] = "ErrorMsg",
            [vim.diagnostic.severity.WARN] = "WarningMsg",
        }
    } or {},
    virtual_lines = false,
    virtual_text = true,
})
