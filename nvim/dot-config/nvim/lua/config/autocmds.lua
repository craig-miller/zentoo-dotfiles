-------------------------------------------------------------------------------
-- Auto Commands
--

-- Highlight when yanking (copying) text
--  Try it with `yap` in normal mode
--  See `:help vim.highlight.on_yank()`
vim.api.nvim_create_autocmd("TextYankPost", {
    desc = "Highlight when yanking (copying) text",
    group = vim.api.nvim_create_augroup("text-highlight-yank", { clear = true }),
    callback = function()
        vim.highlight.on_yank()
    end,
})

-- Strip trailing whitespace when saving.
vim.api.nvim_create_autocmd({ "BufWritePre" }, {
    pattern = { "*" }, -- Apply to all file types, or specify patterns like "*.lua,*.py"
    callback = function()
        -- Save cursor position to restore it after the substitution
        local curpos = vim.api.nvim_win_get_cursor(0)
        -- Execute the substitution command to remove trailing whitespace
        vim.cmd([[keeppatterns %s/\s\+$//e]])
        -- Restore the cursor position
        vim.api.nvim_win_set_cursor(0, curpos)
    end,
})

vim.api.nvim_create_autocmd("BufWritePre", {
    group = vim.api.nvim_create_augroup("LspFormatting", {}),
    callback = function(args)
        local buf = args.buf
        if not vim.lsp.buf_is_attached(buf) then return end

        vim.lsp.buf.format({
            bufnr = buf,
            async = false,
            filter = function(client)
                -- only allow clients that advertise formatting capability
                return client.server_capabilities and client.server_capabilities.documentFormattingProvider
            end,
        })
    end,
})

-- Code Lens support for markdown-oxide reference counts
local function check_codelens_support()
    local clients = vim.lsp.get_clients({ bufnr = 0 })
    for _, c in ipairs(clients) do
        if c.server_capabilities.codeLensProvider then
            return true
        end
    end
    return false
end

vim.api.nvim_create_autocmd({ 'TextChanged', 'InsertLeave', 'CursorHold', 'LspAttach', 'BufEnter' }, {
    group = vim.api.nvim_create_augroup("lsp-codelens", { clear = true }),
    callback = function()
        if check_codelens_support() then
            vim.lsp.codelens.refresh({ bufnr = 0 })
        end
    end,
})

-- Trigger initial codelens refresh
vim.api.nvim_exec_autocmds('User', { pattern = 'LspAttached' })


-- vim.api.nvim_create_autocmd("BufWritePre", {
--     group = vim.api.nvim_create_augroup("LspFormatting", {}),
--     callback = function(args)
--         if vim.lsp.buf_is_attached(args.buf) then
--             vim.lsp.buf.format({ async = false })
--         end
--     end,
-- })

-- Automatically open the trouble.nvim quickfix window if there are Xcodebuild errors
vim.api.nvim_create_autocmd("User", {
    pattern = { "XcodebuildBuildFinished", "XcodebuildTestsFinished" },
    callback = function(event)
        if event.data.cancelled then
            return
        end

        if event.data.success then
            require("trouble").close()
        elseif not event.data.failedCount or event.data.failedCount > 0 then
            -- Get the quickfix list to confirm it has entries
            local qflist = vim.fn.getqflist()

            if next(qflist) then
                -- Open the quickfix list using Trouble
                require("trouble").open("quickfix")
                require("trouble").refresh()

                -- Jump to the first error in the quickfix list
                vim.cmd("cfirst")
            else
                require("trouble").close()
            end
        end
    end,
})

-- Automatically open the Trouble.nvim quickfix window if there are make errors
-- Automatically close the quickfix window if it's open and there are no errors.
vim.api.nvim_create_autocmd("QuickFixCmdPost", {
    pattern = "make",
    callback = function()
        -- Count only "valid" entries (with a real file:line). Build tools
        -- like `swift build` print progress lines that get captured as
        -- text-only entries with valid = 0; Trouble filters those out and
        -- warns "no results", which is what we want to avoid triggering.
        local valid = 0
        for _, e in ipairs(vim.fn.getqflist()) do
            if e.valid == 1 and e.bufnr and e.bufnr > 0 then
                valid = valid + 1
            end
        end
        if valid > 0 then
            vim.cmd("Trouble qflist")
        else
            vim.cmd("Trouble close")
            vim.notify("Build succeeded", vim.log.levels.INFO, { title = "make" })
        end
    end,
})

-- vim.api.nvim_create_autocmd("QuickFixCmdPost", {
--     pattern = "make",
--     callback = function()
--         local qflist = vim.fn.getqflist()
--         if #qflist > 0 then
--             -- Open Trouble quickfix list if errors exist
--             vim.cmd("Trouble qflist")
--         else
--             -- Close Trouble quickfix list if no errors
--             vim.cmd("Trouble close")
--         end
--     end,
-- })

--
-- or without Trouble.nvim
--
-- Automatically open the quickfix window if there are errors during the build.
-- Automatically close the quickfix window if it's open and there are no errors.
-- vim.api.nvim_create_autocmd("QuickFixCmdPost", {
-- 	pattern = "make",
-- 	callback = function()
-- 		local qflist = vim.fn.getqflist()
-- 		if #qflist > 0 then
-- 			vim.cmd("cwindow")
-- 		else
-- 			vim.cmd("cclose")
-- 		end
-- 	end,
-- })
--
--  This function gets run when an LSP attaches to a particular buffer.
--    That is to say, every time a new file is opened that is associated with
--    an lsp (for example, opening `main.rs` is associated with `rust_analyzer`) this
--    function will be executed to configure the current buffer
vim.api.nvim_create_autocmd("LspAttach", {

    group = vim.api.nvim_create_augroup("UserLspConfig", { clear = true }),
    callback = function(event)
        -- We create a function that lets us more easily define mappings specific
        -- for LSP related items. It sets the mode, buffer and description for us each time.
        local map = function(keys, func, desc, mode)
            mode = mode or "n"
            -- vim.keymap.set(mode, keys, func, { buffer = event.buf, desc = "LSP: " .. desc })
            vim.keymap.set(mode, keys, func, { buffer = event.buf, desc = desc })
        end

        -- Rename the variable under your cursor.
        --  Most Language Servers support renaming across files, etc.
        map("<leader>cr", vim.lsp.buf.rename, "[C]ode [R]ename")
        map("cr", vim.lsp.buf.rename, "[C]ode [R]ename")

        -- Execute a code action, usually your cursor needs to be on top of an error
        -- or a suggestion from your LSP for this to activate.
        map("<leader>ca", vim.lsp.buf.code_action, "[C]ode [A]ction", { "n", "x" })
        map("ca", vim.lsp.buf.code_action, "[C]ode [A]ction", { "n", "x" })

        -- Find references for the word under your cursor.
        -- map("<leader>gr", require("fzf-lua").lsp_references, "[G]oto [R]eferences")
        map("gr", require("fzf-lua").lsp_references, "[G]oto [R]eferences")

        -- Jump to the implementation of the word under your cursor.
        --  Useful when your language has ways of declaring types without an actual implementation.
        -- map("<leader>gi", require("fzf-lua").lsp_implementations, "[G]oto [I]mplementation")
        map("gi", require("fzf-lua").lsp_implementations, "[G]oto [I]mplementation")

        -- Jump to the definition of the word under your cursor.
        --  This is where a variable was first declared, or where a function is defined, etc.
        --  To jump back, press <C-t>.
        -- map("<leader>gd", require("fzf-lua").lsp_definitions, "[G]oto [D]efinition")
        map("gd", require("fzf-lua").lsp_definitions, "[G]oto [D]efinition")

        -- WARN: This is not Goto Definition, this is Goto Declaration.
        --  For example, in C this would take you to the header.
        -- map("<leader>gD", vim.lsp.buf.declaration, "[G]oto [D]eclaration")
        map("gD", vim.lsp.buf.declaration, "[G]oto [D]eclaration")

        -- Fuzzy find all the symbols in your current document.
        --  Symbols are things like variables, functions, types, etc.
        -- map("<leader>fs", require("fzf-lua").lsp_document_symbols, "Find Document Symbols")
        map("gs", require("fzf-lua").lsp_document_symbols, "Go Document Symbols")

        -- Fuzzy find all the symbols in your current workspace.
        --  Similar to document symbols, except searches over your entire project.
        -- map("<leader>fS", require("fzf-lua").lsp_workspace_symbols, "Find Workspace Symbols")
        map("gS", require("fzf-lua").lsp_workspace_symbols, "Open Workspace Symbols")

        -- Jump to the type of the word under your cursor.
        --  Useful when you're not sure what type a variable is and you want to see
        --  the definition of its *type*, not where it was *defined*.
        -- map("<leader>gt", require("fzf-lua").lsp_typedefs, "[G]oto [T]ype Definition")
        map("gt", require("fzf-lua").lsp_typedefs, "[G]oto [T]ype Definition")

        vim.api.nvim_exec_autocmds('User', { pattern = 'LspAttached' })
        -- This function resolves a difference between neovim nightly (version 0.11) and stable (version 0.10)
        -- @param client vim.lsp.Client
        -- @param method vim.lsp.protocol.Method
        -- @param bufnr? integer some lsp support methods only in specific files
        -- @return boolean
        local function client_supports_method(client, method, bufnr)
            if vim.fn.has("nvim-0.11") == 1 then
                return client:supports_method(method, bufnr)
            else
                return client.supports_method(method, { bufnr = bufnr })
            end
        end

        -- The following two autocommands are used to highlight references of the
        -- word under your cursor when your cursor rests there for a little while.
        --    See `:help CursorHold` for information about when this is executed
        --
        -- When you move your cursor, the highlights will be cleared (the second autocommand).
        local client = vim.lsp.get_client_by_id(event.data.client_id)
        if
            client
            and client_supports_method(
                client,
                vim.lsp.protocol.Methods.textDocument_documentHighlight,
                event.buf
            )
        then
            local highlight_augroup = vim.api.nvim_create_augroup("lsp-highlight", { clear = false })
            vim.api.nvim_create_autocmd({ "CursorHold", "CursorHoldI" }, {
                buffer = event.buf,
                group = highlight_augroup,
                callback = vim.lsp.buf.document_highlight,
            })

            vim.api.nvim_create_autocmd({ "CursorMoved", "CursorMovedI" }, {
                buffer = event.buf,
                group = highlight_augroup,
                callback = vim.lsp.buf.clear_references,
            })

            vim.api.nvim_create_autocmd("LspDetach", {
                group = vim.api.nvim_create_augroup("lsp-detach", { clear = true }),
                callback = function(event2)
                    vim.lsp.buf.clear_references()
                    vim.api.nvim_clear_autocmds({ group = "lsp-highlight", buffer = event2.buf })
                end,
            })
        end

        -- The following code creates a keymap to toggle inlay hints in your
        -- code, if the language server you are using supports them
        --
        -- This may be unwanted, since they displace some of your code
        if
            client
            and client_supports_method(client, vim.lsp.protocol.Methods.textDocument_inlayHint, event.buf)
        then
            map("<leader>th", function()
                vim.lsp.inlay_hint.enable(not vim.lsp.inlay_hint.is_enabled({ bufnr = event.buf }))
            end, "[T]oggle Inlay [H]ints")
        end
    end,
})

-- Directory-based Notes keybindings
-- Enable <leader>n keybindings when in ~/Notes directory
local function is_notes_vault()
    local cwd = vim.fn.getcwd()
    -- Must be in ~/Notes directory (or subdirectory)
    if not cwd:find(vim.fn.expand("~/Notes")) then
        return false
    end
    -- Must have moxide settings configured (confirms markdown-oxide is set up)
    return vim.fn.filereadable(vim.fn.expand("~/.config/moxide/settings.toml")) == 1
end

local function notes_backlinks()
    local clients = vim.lsp.get_clients({ name = 'markdown_oxide' })
    if #clients > 0 then
        -- Inline implementation of backlinks since the function is local in the LSP config
        local params = vim.lsp.util.make_position_params()
        params.context = { includeDeclaration = false }

        vim.lsp.buf_request(0, 'textDocument/references', params, function(err, result)
            if err then
                vim.notify('Error getting references: ' .. err.message, vim.log.levels.ERROR)
                return
            end
            if not result or vim.tbl_isempty(result) then
                vim.notify('No references found', vim.log.levels.INFO)
                return
            end

            -- Format results for fzf-lua
            local entries = {}
            for _, ref in ipairs(result) do
                local uri = ref.uri
                local range = ref.range
                local filename = vim.uri_to_fname(uri)
                local bufnr = vim.uri_to_bufnr(uri)
                local line_content = vim.api.nvim_buf_get_lines(
                    bufnr, range.start.line, range.start.line + 1, false
                )[1] or ""

                -- Create relative path for cleaner display
                local rel_path = vim.fn.fnamemodify(filename, ':.')
                if rel_path == filename then
                    rel_path = vim.fn.fnamemodify(filename, ':t') -- fallback to just filename
                end

                table.insert(entries, {
                    filename = filename,
                    rel_path = rel_path,
                    lnum = range.start.line + 1,
                    col = range.start.character + 1,
                    text = line_content:gsub("^%s*(.-)%s*$", "%1"), -- trim whitespace
                    display = string.format("%s:%d: %s", rel_path, range.start.line + 1,
                        line_content:gsub("^%s*(.-)%s*$", "%1")),
                })
            end

            -- Sort by filename for better organization
            table.sort(entries, function(a, b)
                return a.rel_path < b.rel_path
            end)

            -- Create mapping from display strings to entries
            local display_to_entry = {}
            for _, entry in ipairs(entries) do
                display_to_entry[entry.display] = entry
            end

            -- Display with fzf-lua
            require('fzf-lua').fzf_exec(
                vim.tbl_map(function(entry) return entry.display end, entries),
                {
                    prompt = 'Backlinks> ',
                    actions = {
                        ['default'] = function(selected)
                            local display_str = selected[1]
                            local entry = display_to_entry[display_str]
                            if entry then
                                vim.cmd('edit ' .. vim.fn.fnameescape(entry.filename))
                                vim.api.nvim_win_set_cursor(0, { entry.lnum, entry.col - 1 })
                            end
                        end,
                    },
                    previewer = 'builtin',
                    winopts = {
                        height = 0.6,
                        width = 0.8,
                    },
                }
            )
        end)
    else
        vim.notify('Backlinks require opening a markdown file first to load markdown-oxide LSP', vim.log.levels.INFO)
    end
end

local function notes_today()
    vim.cmd('Daily today')
end

local function notes_yesterday()
    vim.cmd('Daily yesterday')
end

vim.api.nvim_create_autocmd("DirChanged", {
    group = vim.api.nvim_create_augroup("notes-keybindings", { clear = true }),
    callback = function()
        -- Clear any existing notes keybindings
        pcall(vim.keymap.del, 'n', '<leader>nb')
        pcall(vim.keymap.del, 'n', '<leader>nt')
        pcall(vim.keymap.del, 'n', '<leader>ny')

        -- Set notes keybindings if in Notes vault
        if is_notes_vault() then
            vim.keymap.set('n', '<leader>nb', notes_backlinks, {
                desc = 'Show backlinks for current item (requires LSP)'
            })

            vim.keymap.set('n', '<leader>nt', notes_today, {
                desc = 'Open today\'s daily note'
            })

            vim.keymap.set('n', '<leader>ny', notes_yesterday, {
                desc = 'Open yesterday\'s daily note'
            })
        end
    end,
})

-- Also set keybindings immediately if already in Notes vault on startup
vim.api.nvim_create_autocmd("VimEnter", {
    callback = function()
        if is_notes_vault() then
            vim.keymap.set('n', '<leader>nb', notes_backlinks, {
                desc = 'Show backlinks for current item (requires LSP)'
            })

            vim.keymap.set('n', '<leader>nt', notes_today, {
                desc = 'Open today\'s daily note'
            })

            vim.keymap.set('n', '<leader>ny', notes_yesterday, {
                desc = 'Open yesterday\'s daily note'
            })
        end
    end,
})
