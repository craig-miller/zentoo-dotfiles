-- Typst buffer setup with Calepin awareness.
-- FileType autocmd:
--   - Detects Calepin project (calepin.toml up-tree, or #import "/.calepin/calepin.typ"
--     in the first ten lines of the buffer).
--   - Calepin -> makeprg = "calepin compile %"; <leader>tp toggles the Calepin
--     watch pipeline (see calepin_preview_toggle).
--   - Plain typst -> makeprg = "typst compile %"; <leader>tp -> :TypstPreviewToggle
--     (typst-preview.nvim).
-- Site buffers AND the site's calepin.toml additionally get the Website group
-- (<leader>s):
--   - <leader>sp -> :CalepinPublish (build + POST to Netlify via netlify-publish)
--   - <leader>sb -> :CalepinBuild   (build dist/ only; errors -> quickfix)
--   - <leader>sc -> :CalepinClean   (remove all .calepin/ directories, -y)
-- VimLeavePre autocmd stops any surviving calepin watch + zathura jobs.

local function calepin_detect()
    local buf = vim.fn.expand("%:p")
    if buf == "" then return false, nil, nil end

    local toml = vim.fs.find("calepin.toml", {
        upward = true,
        path = vim.fs.dirname(buf),
    })[1]
    if toml then return true, "site", vim.fs.dirname(toml) end

    local lines = vim.api.nvim_buf_get_lines(0, 0, 10, false)
    for _, line in ipairs(lines) do
        if line:find([[#import "/.calepin/calepin.typ"]], 1, true) then
            return true, "notebook", nil
        end
    end
    return false, nil, nil
end

local calepin_watch_job = nil
local zathura_job = nil

local function calepin_preview_stop()
    if calepin_watch_job then
        pcall(vim.fn.jobstop, calepin_watch_job)
        calepin_watch_job = nil
    end
    if zathura_job then
        pcall(vim.fn.jobstop, zathura_job)
        zathura_job = nil
    end
end

local function calepin_preview_toggle()
    if calepin_watch_job then
        calepin_preview_stop()
        return
    end

    local _, kind, site_root = calepin_detect()
    local buf = vim.fn.expand("%:p")

    if kind == "site" then
        calepin_watch_job = vim.fn.jobstart(
            { "calepin", "watch", site_root, "dist", "--serve", "--open" },
            { cwd = site_root }
        )
    else
        calepin_watch_job = vim.fn.jobstart(
            { "calepin", "watch", buf, "--format", "pdf" }
        )
        local pdf = buf:gsub("%.typ$", ".pdf")
        zathura_job = vim.fn.jobstart({ "zathura", pdf })
    end
end

local function calepin_build_via_make(site_root)
    local saved = vim.opt_local.makeprg:get()
    vim.opt_local.makeprg = "calepin compile "
        .. vim.fn.shellescape(site_root) .. " "
        .. vim.fn.shellescape(site_root .. "/dist")
    vim.cmd("silent make")
    vim.opt_local.makeprg = saved

    local errors = vim.tbl_filter(
        function(e) return e.valid == 1 end,
        vim.fn.getqflist()
    )
    return errors
end

local function calepin_build()
    local is_calepin, kind, site_root = calepin_detect()
    if not is_calepin or kind ~= "site" then
        vim.notify("Website Build: not in a Calepin site buffer",
            vim.log.levels.WARN)
        return
    end

    local errors = calepin_build_via_make(site_root)
    if #errors > 0 then
        vim.cmd("copen")
        vim.notify("Website Build: errors in quickfix", vim.log.levels.ERROR)
        vim.cmd("Noice fzf")
    else
        vim.notify("Website Build: done", vim.log.levels.INFO)
    end
end

local function calepin_publish()
    local is_calepin, kind, site_root = calepin_detect()
    if not is_calepin or kind ~= "site" then
        vim.notify("Website Publish: not in a Calepin site buffer",
            vim.log.levels.WARN)
        return
    end

    local errors = calepin_build_via_make(site_root)
    if #errors > 0 then
        vim.cmd("copen")
        vim.notify("Website Publish: build errors - publish aborted",
            vim.log.levels.ERROR)
        return
    end

    vim.notify("Website Publish: uploading...", vim.log.levels.INFO)
    local output = {}
    vim.fn.jobstart({ "fish", "-c", "netlify-publish" }, {
        cwd = site_root,
        stdout_buffered = true,
        stderr_buffered = true,
        on_stdout = function(_, data)
            if data then
                for _, line in ipairs(data) do
                    if line ~= "" then table.insert(output, line) end
                end
            end
        end,
        on_stderr = function(_, data)
            if data then
                for _, line in ipairs(data) do
                    if line ~= "" then table.insert(output, line) end
                end
            end
        end,
        on_exit = function(_, code)
            vim.schedule(function()
                if code == 0 then
                    local url = output[1] or "(published)"
                    vim.notify("Website Publish: " .. url, vim.log.levels.INFO)
                else
                    vim.notify(
                        "Website Publish: failed (exit " .. code .. ")\n"
                            .. table.concat(output, "\n"),
                        vim.log.levels.ERROR
                    )
                    vim.cmd("Noice fzf")
                end
            end)
        end,
    })
end

local function calepin_clean()
    local is_calepin, _, site_root = calepin_detect()
    if not is_calepin then
        vim.notify("Website Clean: not in a Calepin buffer",
            vim.log.levels.WARN)
        return
    end
    local cwd = site_root or vim.fs.dirname(vim.fn.expand("%:p"))
    vim.fn.jobstart({ "calepin", "clean", "-y" }, {
        cwd = cwd,
        on_exit = function(_, code)
            vim.schedule(function()
                if code ~= 0 then
                    vim.notify(
                        "Website Clean: failed (exit " .. code .. ")",
                        vim.log.levels.ERROR
                    )
                    return
                end
                if site_root then
                    local dist = site_root .. "/dist"
                    if vim.fn.isdirectory(dist) == 1 then
                        vim.fn.delete(dist, "rf")
                    end
                end
                vim.notify("Website Clean: done", vim.log.levels.INFO)
            end)
        end,
    })
end

vim.api.nvim_create_user_command("CalepinPreviewToggle", calepin_preview_toggle, {})
vim.api.nvim_create_user_command("CalepinPublish", calepin_publish, {})
vim.api.nvim_create_user_command("CalepinBuild", calepin_build, {})
vim.api.nvim_create_user_command("CalepinClean", calepin_clean, {})

local function attach_website_group()
    local ok, wk = pcall(require, "which-key")
    if ok then
        wk.add({
            { "<leader>s",  group = "Website", buffer = 0 },
            { "<leader>sp", "<Cmd>CalepinPublish<CR>", desc = "Publish", buffer = 0 },
            { "<leader>sb", "<Cmd>CalepinBuild<CR>",   desc = "Build",   buffer = 0 },
            { "<leader>sc", "<Cmd>CalepinClean<CR>",   desc = "Clean",   buffer = 0 },
        })
    else
        vim.keymap.set("n", "<leader>sp", "<Cmd>CalepinPublish<CR>",
            { buffer = 0, silent = true, desc = "Publish" })
        vim.keymap.set("n", "<leader>sb", "<Cmd>CalepinBuild<CR>",
            { buffer = 0, silent = true, desc = "Build" })
        vim.keymap.set("n", "<leader>sc", "<Cmd>CalepinClean<CR>",
            { buffer = 0, silent = true, desc = "Clean" })
    end
end

vim.api.nvim_create_autocmd("FileType", {
    group = vim.api.nvim_create_augroup("lang-typst", { clear = true }),
    pattern = "typst",
    callback = function()
        vim.opt_local.errorformat = " %#┌─ %f:%l:%c,%trror: %m,%tarning: %m,%-G%.%#"

        local is_calepin, kind = calepin_detect()
        if is_calepin then
            vim.opt_local.makeprg = "calepin compile %"
            vim.keymap.set("n", "<leader>tp", "<Cmd>CalepinPreviewToggle<CR>",
                { buffer = 0, silent = true, desc = "Toggle Preview" })
        else
            vim.opt_local.makeprg = "typst compile %"
            vim.keymap.set("n", "<leader>tp", "<Cmd>TypstPreviewToggle<CR>",
                { buffer = 0, silent = true, desc = "Toggle Preview" })
        end

        local ok, wk = pcall(require, "which-key")
        if ok then
            wk.add({ "<leader>tp", desc = "Toggle Preview", buffer = 0 })
        end

        if is_calepin and kind == "site" then
            attach_website_group()
        end
    end,
})

vim.api.nvim_create_autocmd("FileType", {
    group = vim.api.nvim_create_augroup("lang-calepin-toml", { clear = true }),
    pattern = "toml",
    callback = function()
        local buf = vim.fn.expand("%:p")
        if buf:match("/calepin%.toml$") then
            attach_website_group()
        end
    end,
})

vim.api.nvim_create_autocmd("VimLeavePre", {
    group = vim.api.nvim_create_augroup("lang-typst-cleanup", { clear = true }),
    callback = calepin_preview_stop,
})

return {}
