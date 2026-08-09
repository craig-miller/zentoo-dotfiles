-- Zettelkasten helpers over the ~/research Typst vault + papis library.
-- Reference-first: the low-friction path (<leader>pz) always grounds a card in a
-- paper; an ungrounded card is a deliberate, slightly-longer reach.
--   <leader>pz  new card grounded in a paper (cite + paper-note link prefilled)
--   <leader>pl  insert a paper-note link at the cursor
--   <leader>nc  new UNGROUNDED card (the escape hatch, in the notes namespace)
--   <leader>nl  link to another existing card
-- (<leader>pp = papis.nvim citation insert; <leader>ng = zeta graph — both elsewhere.)

local M = {}

local RESEARCH = vim.fn.expand("~/research")
local NOTES = RESEARCH .. "/notes"
local PAPIS = vim.fn.expand("~/.local/bin/papis")

-- glyphs to tell a paper's high-level review apart from an idea card in pickers
local BOOK = vim.g.have_nerd_font and "" or "[paper]"
local CARD = vim.g.have_nerd_font and "" or "[card]"

local function slugify(s)
    s = s:lower():gsub("[^%w]+", "-")
    return (s:gsub("^-+", ""):gsub("-+$", ""))
end
M._slugify = slugify

-- first `= Heading <Label>` -> "Heading" (trailing <label> stripped)
local function read_title(path)
    local f = io.open(path, "r")
    if not f then return nil end
    for line in f:lines() do
        local h = line:match("^=%s+(.+)")
        if h then
            f:close()
            return vim.trim((h:gsub("%s*<[^>]*>%s*$", "")))
        end
    end
    f:close()
    return nil
end

local function unique_path(dir, base)
    if vim.fn.filereadable(dir .. "/" .. base .. ".typ") == 0 then
        return dir .. "/" .. base .. ".typ"
    end
    local n = 2
    while vim.fn.filereadable(dir .. "/" .. base .. "-" .. n .. ".typ") == 1 do
        n = n + 1
    end
    return dir .. "/" .. base .. "-" .. n .. ".typ"
end

local function open_at(path, lines, cursor_line)
    vim.fn.mkdir(NOTES, "p")
    if vim.fn.filereadable(path) == 0 then
        vim.fn.writefile(lines, path)
    end
    vim.cmd.edit(path)
    if cursor_line then
        vim.api.nvim_win_set_cursor(0, { cursor_line, 0 })
    end
end

local function put(text)
    vim.api.nvim_put({ text }, "c", true, true)
end

-- pick a paper from the papis library; cb(ref) with the chosen citekey.
-- systemlist with a list arg execs papis directly (no shell) — dodges fish quoting.
local function pick_paper(prompt, cb)
    local lines = vim.fn.systemlist(
        { PAPIS, "list", "--all", "--format", "{doc[ref]}    {doc[title]}" })
    if vim.v.shell_error ~= 0 or #lines == 0 then
        vim.notify("papis list returned nothing", vim.log.levels.ERROR)
        return
    end
    lines = vim.tbl_filter(function(l) return l ~= "" end, lines)
    require("fzf-lua").fzf_exec(lines, {
        prompt = prompt,
        actions = {
            ["default"] = function(sel)
                local ref = sel and sel[1] and sel[1]:match("^(%S+)")
                if ref then cb(ref) end
            end,
        },
    })
end

-- pick an existing card in ~/research/notes; cb(name, title).
local function pick_card(prompt, cb)
    local entries, meta = {}, {}
    for name, typ in vim.fs.dir(NOTES) do
        if typ == "file" and name:match("%.typ$") then
            local base = name:gsub("%.typ$", "")
            local title = read_title(NOTES .. "/" .. name) or base
            local display = title .. "  ::  " .. base
            entries[#entries + 1] = display
            meta[display] = { name = base, title = title }
        end
    end
    table.sort(entries)
    if #entries == 0 then
        vim.notify("no cards in " .. NOTES .. " yet", vim.log.levels.WARN)
        return
    end
    require("fzf-lua").fzf_exec(entries, {
        prompt = prompt,
        actions = {
            ["default"] = function(sel)
                local m = sel and sel[1] and meta[sel[1]]
                if m then cb(m.name, m.title) end
            end,
        },
    })
end

-- every note in the vault: idea cards (notes/*.typ) + paper reviews (papers/<ref>/notes.typ).
-- cb(path, title, kind, ref) — kind is "card" or "paper".
local function iter_vault_notes(cb)
    for name, typ in vim.fs.dir(NOTES) do
        if typ == "file" and name:match("%.typ$") then
            local p = NOTES .. "/" .. name
            cb(p, read_title(p) or name:gsub("%.typ$", ""), "card", nil)
        end
    end
    local papers = RESEARCH .. "/papers"
    if vim.fn.isdirectory(papers) == 1 then
        for ref, typ in vim.fs.dir(papers) do
            if typ == "directory" then
                local p = papers .. "/" .. ref .. "/notes.typ"
                if vim.fn.filereadable(p) == 1 then
                    cb(p, read_title(p) or ref, "paper", ref)
                end
            end
        end
    end
end

-- build the fzf display list once; returns entries + display->path map
local function vault_entries()
    local entries, meta = {}, {}
    iter_vault_notes(function(path, title, kind, ref)
        local display = (kind == "paper")
            and (BOOK .. "  " .. title .. "  (" .. ref .. ")")
            or (CARD .. "  " .. title)
        while meta[display] do display = display .. " " end -- keep keys unique
        entries[#entries + 1] = display
        meta[display] = path
    end)
    table.sort(entries)
    return entries, meta
end
M._vault_entries = function() return (vault_entries()) end

-- templates: new cards are born <Fleeting>; flip to <Idea> once processed.
local function grounded_lines(title, ref)
    return {
        "= " .. title .. " <Fleeting>",
        "",
        "// paste the quote / fleeting thought, then rewrite it below",
        "",
        "== In my own words",
        "",
        "== Source",
        '#link("papers/' .. ref .. '/notes")[' .. ref .. "] · see @" .. ref,
        "",
        "== Links",
        "",
    }
end
M._grounded_lines = grounded_lines

local function ungrounded_lines(title)
    return {
        "= " .. title .. " <Fleeting>",
        "",
        "== In my own words",
        "",
        "== Links",
        "",
    }
end

function M.new_grounded()
    pick_paper("Paper for new card> ", function(ref)
        vim.ui.input({ prompt = "Card title: " }, function(title)
            if not title or title == "" then return end
            local path = unique_path(NOTES, ref .. "-" .. slugify(title))
            open_at(path, grounded_lines(title, ref), 6) -- empty line under "In my own words"
        end)
    end)
end

function M.new_ungrounded()
    vim.ui.input({ prompt = "Card title: " }, function(title)
        if not title or title == "" then return end
        local path = unique_path(NOTES, slugify(title))
        open_at(path, ungrounded_lines(title), 4)
    end)
end

function M.insert_paper_link()
    pick_paper("Link paper-note> ", function(ref)
        put('#link("papers/' .. ref .. '/notes")[' .. ref .. "]")
    end)
end

function M.insert_card_link()
    pick_card("Link card> ", function(name, title)
        put('#link("notes/' .. name .. '")[' .. title .. "]")
    end)
end

-- find & open any note in the vault (cards + paper reviews), cwd-independent
function M.find_note()
    local entries, meta = vault_entries()
    if #entries == 0 then
        vim.notify("no notes in the vault yet", vim.log.levels.WARN)
        return
    end
    require("fzf-lua").fzf_exec(entries, {
        prompt = "Find note> ",
        actions = {
            ["default"] = function(sel)
                local p = sel and sel[1] and meta[sel[1]]
                if p then vim.cmd.edit(p) end
            end,
        },
    })
end

-- Follow the #link on the current line from ANY column (zeta only resolves gd
-- when the cursor is exactly on the quoted path). Falls back to the normal LSP
-- definition when the line has no link.
function M.follow_link()
    local line = vim.api.nvim_get_current_line()
    local col = vim.api.nvim_win_get_cursor(0)[2] -- 0-indexed
    local best, best_dist, init = nil, nil, 1
    while true do
        local s, e, target = line:find('#link%(%s*"([^"]-)"', init)
        if not s then break end
        local dist = (col < s - 1) and (s - 1 - col) or (col > e - 1) and (col - (e - 1)) or 0
        if not best_dist or dist < best_dist then best, best_dist = target, dist end
        init = e + 1
    end
    if not best then
        require("fzf-lua").lsp_definitions() -- no link here: normal gd
        return
    end
    local path = best:match("%.%w+$") and best or (best .. ".typ")
    local fname = vim.api.nvim_buf_get_name(0)
    local resolved
    if path:sub(1, 1) == "." then -- relative to the note (zeta's rule)
        resolved = vim.fs.normalize(vim.fs.dirname(fname) .. "/" .. path)
    else -- root-relative (root = nearest typst.toml/.git, i.e. ~/research)
        local root = vim.fs.root(fname, { "typst.toml", ".git" }) or RESEARCH
        resolved = vim.fs.normalize(root .. "/" .. path)
    end
    vim.cmd.edit(resolved)
end

-- override gd on Typst buffers (registered after the generic LspAttach map, so
-- it wins) — makes gd follow a #link no matter where on the line the cursor is.
vim.api.nvim_create_autocmd("LspAttach", {
    group = vim.api.nvim_create_augroup("zettel-gd", { clear = true }),
    callback = function(ev)
        if vim.bo[ev.buf].filetype == "typst" then
            vim.keymap.set("n", "gd", M.follow_link,
                { buffer = ev.buf, desc = "Follow link / definition" })
        end
    end,
})

local function map(lhs, fn, desc)
    vim.keymap.set("n", lhs, fn, { desc = desc })
end
map("<leader>pz", M.new_grounded, "New card from paper")
map("<leader>pl", M.insert_paper_link, "Insert paper-note link")
map("<leader>nc", M.new_ungrounded, "New card (ungrounded)")
map("<leader>nl", M.insert_card_link, "Link to card")
map("<leader>fn", M.find_note, "Find note")

local ok_wk, wk = pcall(require, "which-key")
if ok_wk then
    wk.add({
        { "<leader>pz", desc = "New card from paper" },
        { "<leader>pl", desc = "Insert paper-note link" },
        { "<leader>nc", desc = "New card (ungrounded)" },
        { "<leader>nl", desc = "Link to card" },
        { "<leader>fn", desc = "Find note" },
    })
end

return M
