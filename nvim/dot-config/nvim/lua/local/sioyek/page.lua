-- PDF page-number derivation from absolute-y offset.
-- Uses `mutool pages` (proper per-page XML) rather than `mutool info`
-- (which collapses identical MediaBoxes into a single summary line,
-- unmappable to page indexes).

local M = {}

local heights_cache = {}

-- Return list of per-page heights in PDF points (index 1 = page 1).
-- Cached per PDF path for the process lifetime — mutool is not free.
function M.heights(pdf_path)
    if heights_cache[pdf_path] then return heights_cache[pdf_path] end

    local result = vim.system({ "mutool", "pages", pdf_path }, { text = true }):wait()
    if result.code ~= 0 then return nil end

    local heights = {}
    -- Format: <MediaBox l="0" b="0" r="612" t="792" />
    for b, t in result.stdout:gmatch(
        '<MediaBox%s+l="[^"]*"%s+b="([^"]+)"%s+r="[^"]*"%s+t="([^"]+)"'
    ) do
        table.insert(heights, tonumber(t) - tonumber(b))
    end

    heights_cache[pdf_path] = heights
    return heights
end

-- Given per-page heights and an absolute-y offset, return the 1-indexed
-- page number containing that offset (last page if past the end).
function M.page_for_y(heights, y)
    local acc = 0
    for i, h in ipairs(heights) do
        if acc + h >= y then return i end
        acc = acc + h
    end
    return #heights > 0 and #heights or 1
end

-- Convenience: compute page directly from pdf path + y. Uses the cache.
function M.page_of(pdf_path, y)
    local heights = M.heights(pdf_path)
    if not heights or #heights == 0 then return 1 end
    return M.page_for_y(heights, y)
end

-- Split an absolute y-offset into (1-indexed page, page-relative y).
-- Used to feed sioyek's `--page N --yloc REL_Y` cold-start form of
-- goto-highlight (works whether or not the doc is already open, unlike
-- `--execute-command goto_highlight` which races with doc-open).
function M.page_and_rel_y(pdf_path, y)
    local heights = M.heights(pdf_path)
    if not heights or #heights == 0 then return 1, y end
    local acc = 0
    for i, h in ipairs(heights) do
        if acc + h >= y then return i, y - acc end
        acc = acc + h
    end
    -- Past the end of the doc — return last page with y clamped inside it.
    return #heights, y - (acc - heights[#heights])
end

return M
