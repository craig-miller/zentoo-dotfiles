-- Sioyek shared.db / local.db access via the sqlite3 CLI.
-- We use `sqlite3 -json` so the wire format handles arbitrary quote/text
-- content inside highlight `desc` and `text_annot` fields safely — a
-- delimiter-based format would break the first time a highlight contained
-- a newline or the separator char.

local M = {}

local SHARED_DB = vim.fn.expand("~/.local/share/sioyek/shared.db")
local LOCAL_DB = vim.fn.expand("~/.local/share/sioyek/local.db")

local function query(db, sql)
    local result = vim.system({ "sqlite3", "-json", db, sql }, { text = true }):wait()
    if result.code ~= 0 then
        vim.notify(
            "sioyek db query failed: " .. (result.stderr or "?"),
            vim.log.levels.ERROR
        )
        return nil
    end
    if not result.stdout or result.stdout == "" then
        return {}
    end
    local ok, decoded = pcall(vim.json.decode, result.stdout)
    if not ok then
        vim.notify("sioyek db: bad JSON response", vim.log.levels.ERROR)
        return nil
    end
    return decoded
end

-- Every highlight in shared.db. Each row is a dict with keys:
--   uuid, document_path (hash), desc, text_annot, begin_y, type
function M.all_highlights()
    return query(
        SHARED_DB,
        [[SELECT uuid, document_path,
                 coalesce(desc, '') AS desc,
                 coalesce(text_annot, '') AS text_annot,
                 begin_y,
                 type
          FROM highlights]]
    )
end

-- Resolve a sioyek content-hash → filesystem path. Multiple entries per
-- hash are possible (sioyek re-hashes on some events); we take the first.
function M.path_for_hash(hash)
    local rows = query(
        LOCAL_DB,
        string.format(
            "SELECT path FROM document_hash WHERE hash = '%s' LIMIT 1",
            hash:gsub("'", "''")
        )
    )
    return rows and rows[1] and rows[1].path or nil
end

-- Single-highlight lookup by UUID. Returns {doc_hash, begin_y} or nil.
function M.highlight_by_uuid(uuid)
    local rows = query(
        SHARED_DB,
        string.format(
            [[SELECT document_path AS doc_hash, begin_y
              FROM highlights WHERE uuid = '%s' LIMIT 1]],
            uuid:gsub("'", "''")
        )
    )
    if not rows or #rows == 0 then return nil end
    return { doc_hash = rows[1].doc_hash, begin_y = rows[1].begin_y }
end

return M
