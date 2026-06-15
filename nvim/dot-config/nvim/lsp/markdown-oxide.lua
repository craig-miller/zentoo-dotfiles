---@brief
---
--- https://github.com/Feel-ix-343/markdown-oxide
---
--- Editor Agnostic PKM: you bring the text editor and we
--- bring the PKM.
---
--- Inspired by and compatible with Obsidian.
---
--- Check the readme to see how to properly setup.

---@param client vim.lsp.Client
---@param bufnr integer
---@param cmd string
local function command_factory(client, bufnr, cmd)
    return client:exec_cmd({
        title = ('Markdown-Oxide-%s'):format(cmd),
        command = 'jump',
        arguments = { cmd },
    }, { bufnr = bufnr })
end

-- Date parsing function for natural language
local function parse_date_input(input)
    if not input or input == "" then
        return "today"
    end

    -- Convert to lowercase for easier matching
    input = input:lower():gsub("^%s*(.-)%s*$", "%1") -- trim whitespace

    -- Handle basic commands
    if input == "today" then return "today" end
    if input == "tomorrow" then return "tomorrow" end
    if input == "yesterday" then return "yesterday" end

    -- Handle natural language patterns
    -- "X days ago", "X weeks ago", etc.
    local num, unit = input:match("(%d+)%s*(%w+)%s+ago")
    if num and unit then
        num = tonumber(num)
        if unit:match("^day") then
            return string.format("%d days ago", num)
        elseif unit:match("^week") then
            return string.format("%d weeks ago", num)
        elseif unit:match("^month") then
            return string.format("%d months ago", num)
        end
    end

    -- Handle "last/previous X" patterns
    local last_match = input:match("last%s+(%w+)")
    if last_match then
        if last_match == "week" then return "last week"
        elseif last_match == "month" then return "last month"
        elseif last_match:match("monday|tuesday|wednesday|thursday|friday|saturday|sunday") then
            return "last " .. last_match
        end
    end

    -- Handle "next X" patterns
    local next_match = input:match("next%s+(%w+)")
    if next_match then
        if next_match:match("monday|tuesday|wednesday|thursday|friday|saturday|sunday") then
            return "next " .. next_match
        elseif next_match == "week" then return "next week"
        elseif next_match == "month" then return "next month"
        end
    end

    -- Handle "X days ago" (single day)
    local single_day = input:match("(%d+)%s+days?%s+ago")
    if single_day then
        return string.format("%d days ago", tonumber(single_day))
    end

    -- If no pattern matches, pass through as-is (let markdown-oxide handle it)
    return input
end

-- Enhanced capabilities for markdown-oxide
local function get_enhanced_capabilities()
    local base_capabilities = require("blink.cmp").get_lsp_capabilities()
    return vim.tbl_deep_extend(
        'force',
        base_capabilities,
        {
            workspace = {
                didChangeWatchedFiles = {
                    dynamicRegistration = true,
                },
            },
        }
    )
end

-- Backlinks function using fzf-lua
local function show_backlinks()
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
                display = string.format("%s:%d: %s", rel_path, range.start.line + 1, line_content:gsub("^%s*(.-)%s*$", "%1")),
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
                            vim.api.nvim_win_set_cursor(0, {entry.lnum, entry.col - 1})
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
end

---@type vim.lsp.Config
return {
    capabilities = get_enhanced_capabilities(),
    root_markers = { '.git', '.obsidian', '.moxide.toml' },
    filetypes = { 'markdown' },
    cmd = { 'markdown-oxide' },
    on_attach = function(client, bufnr)
        -- Enhanced Daily command with natural language support
        vim.api.nvim_buf_create_user_command(bufnr, "Daily", function(args)
            local input = args.args
            local parsed_date = parse_date_input(input)

            client:exec_cmd({
                title = ('Markdown-Oxide-Daily-%s'):format(parsed_date),
                command = 'jump',
                arguments = { parsed_date },
            }, { bufnr = bufnr })
        end, {
            desc = 'Open daily note with natural language support (e.g., "two days ago", "next monday")',
            nargs = "*",
        })

        -- Notes-related keybindings (<leader>n prefix)
        vim.keymap.set('n', '<leader>nb', show_backlinks, {
            buffer = bufnr,
            desc = 'Show backlinks for current item'
        })

        vim.keymap.set('n', '<leader>nt', function()
            vim.cmd('Daily today')
        end, {
            buffer = bufnr,
            desc = 'Open today\'s daily note'
        })

        vim.keymap.set('n', '<leader>ny', function()
            vim.cmd('Daily yesterday')
        end, {
            buffer = bufnr,
            desc = 'Open yesterday\'s daily note'
        })

        -- Keep existing commands for backward compatibility
        for _, cmd in ipairs({ 'today', 'tomorrow', 'yesterday' }) do
            vim.api.nvim_buf_create_user_command(bufnr, 'Lsp' .. ('%s'):format(cmd:gsub('^%l', string.upper)), function()
                command_factory(client, bufnr, cmd)
            end, {
                desc = ('Open %s daily note'):format(cmd),
            })
        end
    end,
}
