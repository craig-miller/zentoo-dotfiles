-- 1. Setup Mason first
require("mason").setup()

-- 2. Optional: Add Mason's bin to Neovim's PATH
-- This allows you to just use 'yaml-language-server' in cmd
local mason_bin = vim.fn.stdpath("data") .. "/mason/bin"
vim.env.PATH = mason_bin .. ":" .. vim.env.PATH

-- Configure LSP servers
vim.lsp.enable({
    "lua-language-server",
    "sourcekit-lsp",
    "tinymist",
    "zeta",
    -- "bibli_ls"
})

-- Neovim 0.12 enables LSP document-color highlighting by default.
-- Tinymist reports Typst colors and Neovim paints the whole color call
-- with a background. We use nvim-highlight-colors virtual swatches instead.
vim.lsp.document_color.enable(false)

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
