-- Telescope picker over all sioyek highlights (all colors, all docs).
-- Bound to <leader>ph.
--
-- Rows are labeled `<citekey>-<80-char preview>`, sorted alphabetically
-- by citekey then page-ascending. Preview pane shows a small header
-- (citekey, page, PDF filename) followed by the full quote text.
-- Enter inserts the formatted Typst #quote + UUID marker at cursor.
-- <C-o> opens the source PDF in sioyek at the highlight's location.

local db = require("local.sioyek.db")
local page_mod = require("local.sioyek.page")

local M = {}

local MAX_PREVIEW_LEN = 80

local function flat_text(s)
    return (s:gsub("%s+", " "):gsub("^%s+", ""):gsub("%s+$", ""))
end

local function truncate(s, n)
    if #s <= n then return s end
    return s:sub(1, n - 1) .. "\u{2026}"
end

-- Build picker entries. One SQL query for all highlights, then a per-hash
-- fs-path cache and per-pdf mutool-heights cache to avoid N shellouts.
local function build_entries()
    local highlights = db.all_highlights()
    if not highlights then return {} end

    local path_cache = {}  -- doc_hash -> {path, citekey}
    local entries = {}

    for _, h in ipairs(highlights) do
        local cache = path_cache[h.document_path]
        if not cache then
            local path = db.path_for_hash(h.document_path)
            local citekey
            if path then
                citekey = path:match("/papers/([^/]+)/")
                    or vim.fn.fnamemodify(path, ":t:r")  -- basename fallback
            end
            cache = { path = path, citekey = citekey }
            path_cache[h.document_path] = cache
        end

        if cache.path and cache.citekey then
            local text = flat_text(h.desc or "")
            if #text > 0 then
                local page = page_mod.page_of(cache.path, tonumber(h.begin_y))
                local preview = truncate(text, MAX_PREVIEW_LEN)
                table.insert(entries, {
                    citekey = cache.citekey,
                    page = page,
                    text = text,
                    note = h.text_annot or "",
                    pdf_path = cache.path,
                    pdf_name = vim.fn.fnamemodify(cache.path, ":t"),
                    uuid = h.uuid,
                    begin_y = tonumber(h.begin_y),
                    label = string.format("%s  %s", cache.citekey, preview),
                })
            end
        end
    end

    table.sort(entries, function(a, b)
        if a.citekey ~= b.citekey then return a.citekey < b.citekey end
        return (a.page or 0) < (b.page or 0)
    end)

    return entries
end

local function insertion_lines(entry)
    -- Layout separates concerns so the user can copy the quote (with its
    -- plain @ref attribution) cleanly into external writing without a
    -- machine-local file:// link tagging along:
    --
    --   <note (if present)>
    --
    --   #quote(attribution: [@Cite[p. N]])[text]
    --   // sioyek:{uuid}                    <- machine marker for <leader>pj
    --   #link("file://…pdf#page=N+1")[source]  <- reader helper, opens sioyek
    --
    -- The source-link URL uses page+1 because sioyek's --page is off-by-one
    -- (arg N -> shows display page N-1); xdg-open on zentoo routes
    -- file://…#page=N to `sioyek --page N`.
    local quote = string.format(
        "#quote(attribution: [@%s[p. %d]])[%s]",
        entry.citekey, entry.page, entry.text
    )
    -- Sioyek's file:// link handler resolves the path relative to the
    -- CURRENT doc's folder via `Path(doc).file_parent().slash(path)` — its
    -- concatenate_path is dumb about absolute paths ("parent" + "/abs" =
    -- "parent//abs"). Since our source PDF and the notes hub live in the
    -- same paper folder, the basename resolves correctly relative to
    -- notes.pdf's location. Fallback for cards inserted elsewhere: caller
    -- needs to be in a matching folder, or the link will 404.
    local source_link = string.format(
        '#link("file://%s#page=%d")[source]',
        entry.pdf_name, entry.page + 1
    )

    local lines = {}
    if entry.note and #entry.note > 0 then
        for line in vim.gsplit(entry.note, "\n", { plain = true }) do
            table.insert(lines, line)
        end
        table.insert(lines, "")
    end
    table.insert(lines, quote)
    table.insert(lines, string.format("// sioyek:%s", entry.uuid))
    table.insert(lines, source_link)
    return lines
end

function M.pick()
    local pickers = require("telescope.pickers")
    local finders = require("telescope.finders")
    local conf = require("telescope.config").values
    local actions = require("telescope.actions")
    local action_state = require("telescope.actions.state")
    local previewers = require("telescope.previewers")

    local entries = build_entries()
    if #entries == 0 then
        vim.notify("No sioyek highlights found", vim.log.levels.WARN)
        return
    end

    pickers.new({}, {
        prompt_title = "Sioyek highlights",
        finder = finders.new_table({
            results = entries,
            entry_maker = function(e)
                return {
                    value = e,
                    display = e.label,
                    ordinal = e.label,
                }
            end,
        }),
        sorter = conf.generic_sorter({}),
        previewer = previewers.new_buffer_previewer({
            title = "Quote",
            define_preview = function(self, entry)
                local e = entry.value
                local lines = {
                    "Cite: @" .. e.citekey,
                    "Page: " .. tostring(e.page),
                    "PDF:  " .. e.pdf_name,
                    "",
                }
                for line in vim.gsplit(e.text, "\n", { plain = true }) do
                    table.insert(lines, line)
                end
                if e.note and #e.note > 0 then
                    table.insert(lines, "")
                    table.insert(lines, "-- your note --")
                    for line in vim.gsplit(e.note, "\n", { plain = true }) do
                        table.insert(lines, line)
                    end
                end
                vim.api.nvim_buf_set_lines(self.state.bufnr, 0, -1, false, lines)
                vim.wo[self.state.winid].wrap = true
            end,
        }),
        attach_mappings = function(_, map)
            actions.select_default:replace(function(prompt_bufnr)
                actions.close(prompt_bufnr)
                local sel = action_state.get_selected_entry()
                if not sel then return end
                local lines = insertion_lines(sel.value)
                local row = vim.api.nvim_win_get_cursor(0)[1]
                vim.api.nvim_buf_set_lines(0, row, row, false, lines)
                vim.api.nvim_win_set_cursor(0, { row + #lines, 0 })
            end)
            map({ "i", "n" }, "<C-o>", function(prompt_bufnr)
                actions.close(prompt_bufnr)
                local sel = action_state.get_selected_entry()
                if not sel then return end
                local e = sel.value
                -- Use --page/--yloc (cold-start-safe) not --execute-command
                -- goto_highlight (races with doc-open when not already open).
                local rel_y = e.begin_y
                local heights = page_mod.heights(e.pdf_path)
                if heights and #heights > 0 then
                    local acc = 0
                    for i = 1, e.page - 1 do acc = acc + heights[i] end
                    rel_y = e.begin_y - acc
                end
                vim.fn.jobstart({
                    "sioyek",
                    e.pdf_path,
                    "--page", tostring(e.page),
                    "--yloc", tostring(rel_y),
                }, { detach = true })
            end)
            return true
        end,
    }):find()
end

return M
