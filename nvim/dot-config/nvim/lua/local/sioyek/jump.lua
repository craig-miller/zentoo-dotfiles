-- Jump-back from any .typ file to the source PDF in sioyek.
-- Bound to <leader>pj.
--
-- Resolution ladder (matches the spec locked in Task #17):
--   1. Current line + next line → look for `// sioyek:{uuid}` marker.
--      If found, SQL-resolve uuid → doc-hash → fs-path + begin_y →
--      shell `sioyek <pdf> --execute-command goto_highlight
--      --execute-command-data <begin_y>`. Sioyek scrolls the running
--      window (if it has the doc open) or opens fresh.
--   2. Else, scan whole buffer for markers. If ≥ 1, show a telescope
--      picker; on select, jump as above.
--   3. Else, infer citekey (buffer path folder OR nearest @ref) and
--      open the paper's PDF in sioyek (no y-jump).
--   4. Else, notify "no source anchored".
--
-- If a uuid isn't in shared.db anymore (user deleted the highlight in
-- sioyek), fall back to step 3.

local db = require("local.sioyek.db")
local page_mod = require("local.sioyek.page")

local M = {}

local MARKER_PATTERN = "//%s*sioyek:(%b{})"

local function marker_on_lines(lines)
    for _, line in ipairs(lines) do
        local uuid = line:match(MARKER_PATTERN)
        if uuid then return uuid end
    end
    return nil
end

-- Look at current line + next line only. Any wider scan is deferred to
-- the whole-buffer picker.
local function marker_near_cursor()
    local row = vim.api.nvim_win_get_cursor(0)[1]  -- 1-indexed
    local lines = vim.api.nvim_buf_get_lines(0, row - 1, row + 1, false)
    return marker_on_lines(lines)
end

local function all_markers_in_buffer()
    local lines = vim.api.nvim_buf_get_lines(0, 0, -1, false)
    local markers = {}
    for i, line in ipairs(lines) do
        local uuid = line:match(MARKER_PATTERN)
        if uuid then
            -- Snippet: the line above the marker usually holds the quote.
            local snippet = lines[i - 1] or ""
            snippet = snippet:gsub("%s+", " "):gsub("^%s+", ""):gsub("%s+$", "")
            table.insert(markers, {
                line = i,
                uuid = uuid,
                snippet = snippet,
            })
        end
    end
    return markers
end

-- Infer citekey for open-paper fallback.
--   a) Buffer path matches ~/research/papers/<citekey>/... → citekey.
--   b) Else scan buffer for @Foo1234-style refs, prefer nearest to cursor.
local function infer_citekey()
    local path = vim.api.nvim_buf_get_name(0)
    if path and path ~= "" then
        local from_path = path:match("/research/papers/([^/]+)/")
        if from_path then return from_path end
    end

    local row = vim.api.nvim_win_get_cursor(0)[1]
    local lines = vim.api.nvim_buf_get_lines(0, 0, -1, false)
    local best, best_dist
    for i, line in ipairs(lines) do
        for ref in line:gmatch("@(%a[%w_]*%d%d%d%d)") do
            local dist = math.abs(i - row)
            if not best or dist < best_dist then
                best = ref
                best_dist = dist
            end
        end
    end
    return best
end

-- Find the source PDF for a citekey in the papis layout. Excludes
-- notes.pdf (typst render output).
local function pdf_for_citekey(citekey)
    local folder = vim.fn.expand("~/research/papers/" .. citekey)
    if vim.fn.isdirectory(folder) == 0 then return nil end
    local pdfs = vim.fn.glob(folder .. "/*.pdf", false, true)
    for _, p in ipairs(pdfs) do
        if not p:match("/notes%.pdf$") then
            return p
        end
    end
    return nil
end

-- Two-step to work reliably in both cold-open and already-open cases:
--   1. `sioyek <pdf> --page N --yloc REL_Y` — opens the doc (goes through
--      open_document_at_location, which is cold-open-safe) and lands
--      roughly on the right page. Yloc positioning is close but has been
--      observed to be off-by-view-height on some cold-opens.
--   2. After a short delay, `sioyek <pdf> --execute-command goto_highlight
--      --execute-command-data <ABS_Y>` — hits the now-running instance,
--      set_offset_y(abs_y) centers precisely. Known to be correct when
--      dispatched to an already-open instance.
-- If sioyek was already open, step 1 no-ops the open and step 2 does the
-- work. If cold, step 1 spawns and step 2 refines. Uses vim.fn.jobstart
-- (not vim.system) — cold-open sioyek needs a fully-detached spawn that
-- vim.system's detach didn't reliably provide.
local function sioyek_jump(pdf_path, begin_y)
    local page, rel_y = page_mod.page_and_rel_y(pdf_path, begin_y)
    vim.fn.jobstart({
        "sioyek",
        pdf_path,
        "--page", tostring(page),
        "--yloc", tostring(rel_y),
    }, { detach = true })
    vim.defer_fn(function()
        vim.fn.jobstart({
            "sioyek",
            pdf_path,
            "--execute-command", "goto_highlight",
            "--execute-command-data", tostring(begin_y),
        }, { detach = true })
    end, 500)
end

local function sioyek_open(pdf_path)
    vim.fn.jobstart({ "sioyek", pdf_path }, { detach = true })
end

-- uuid (with braces) → (pdf_path, begin_y). nil if uuid not in DB or
-- doc-hash doesn't resolve to a filesystem path.
local function resolve_uuid(uuid)
    local h = db.highlight_by_uuid(uuid)
    if not h then return nil end
    local pdf = db.path_for_hash(h.doc_hash)
    if not pdf then return nil end
    return pdf, tonumber(h.begin_y)
end

-- Fallback: infer citekey → find PDF → open sioyek on it (no y-jump).
local function open_source_fallback(reason)
    local citekey = infer_citekey()
    if not citekey then
        vim.notify(
            (reason or "no marker") .. "; no @citekey inferrable either",
            vim.log.levels.WARN
        )
        return
    end
    local pdf = pdf_for_citekey(citekey)
    if not pdf then
        vim.notify(
            (reason or "no marker") .. "; no PDF for @" .. citekey,
            vim.log.levels.WARN
        )
        return
    end
    sioyek_open(pdf)
    if reason then
        vim.notify(reason .. "; opened @" .. citekey, vim.log.levels.INFO)
    end
end

-- Telescope picker over all buffer markers. Selection jumps.
local function pick_marker(markers)
    local pickers = require("telescope.pickers")
    local finders = require("telescope.finders")
    local conf = require("telescope.config").values
    local actions = require("telescope.actions")
    local action_state = require("telescope.actions.state")

    pickers.new({}, {
        prompt_title = "Sioyek markers in buffer",
        finder = finders.new_table({
            results = markers,
            entry_maker = function(m)
                return {
                    value = m,
                    display = string.format("L%d  %s", m.line, m.snippet:sub(1, 80)),
                    ordinal = m.snippet,
                }
            end,
        }),
        sorter = conf.generic_sorter({}),
        attach_mappings = function(_, _)
            actions.select_default:replace(function(prompt_bufnr)
                actions.close(prompt_bufnr)
                local sel = action_state.get_selected_entry()
                if not sel then return end
                local pdf, y = resolve_uuid(sel.value.uuid)
                if not pdf then
                    open_source_fallback("uuid not in DB")
                    return
                end
                sioyek_jump(pdf, y)
            end)
            return true
        end,
    }):find()
end

function M.jump()
    -- Step 1: marker right under cursor.
    local uuid = marker_near_cursor()
    if uuid then
        local pdf, y = resolve_uuid(uuid)
        if pdf then
            sioyek_jump(pdf, y)
            return
        end
        open_source_fallback("uuid not in DB")
        return
    end

    -- Step 2: scan whole buffer.
    local markers = all_markers_in_buffer()
    if #markers > 0 then
        pick_marker(markers)
        return
    end

    -- Step 3: open-paper fallback.
    open_source_fallback()
end

return M
