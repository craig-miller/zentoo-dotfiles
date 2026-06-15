return {
    cmd = { "bibli_ls" },
    filetypes = {
        "markdown", "quarto",
    },
    root_markers = { ".bibli.toml" },
    -- Optional: visit the URL of the citation with LSP DocumentImplementation
    on_attach = function()
        vim.keymap.set({ "n" }, "<cr>", function()
            vim.lsp.buf.implementation()
        end)
    end,
    single_file_support = true,
    log_level = vim.lsp.protocol.MessageType.Warning,
}

-- cmd = { "bibli_ls" },
-- 	filetypes = { "markdown", "quarto" },
-- 	root_markers = { ".bibli.toml" },
-- 	-- Optional: visit the URL of the citation with LSP DocumentImplementation
-- 	on_attach = function(client, bufnr)
-- 		vim.keymap.set({ "n" }, "<cr>", function()
-- 			vim.lsp.buf.implementation()
-- 		end)
-- 	end,
-- })
