-- YAML buffer setup with RenderCV awareness.
--
-- RenderCV preview is intentionally scoped to ~/docs/cv. YAML files are common
-- across many project types, and this CV directory has no unique marker file, so
-- the hard-coded root prevents <leader>tp from shadowing unrelated YAML buffers.
--
-- In ~/docs/cv/*.yaml, <leader>tp toggles:
--   - `rendercv render <file> --watch`
--   - the generated PDF in zathura
-- VimLeavePre stops any surviving RenderCV watch + zathura jobs.

local CV_ROOT = vim.fn.expand("~/docs/cv")

local rendercv_watch_job = nil
local rendercv_stopping = false
local zathura_job = nil

local function realpath(path)
    return vim.uv.fs_realpath(path)
end

local function path_is_under(path, root)
    local real_root = realpath(root)
    local real_path = realpath(path)
    if not real_root or not real_path then return false end

    real_root = real_root:gsub("/+$", "")
    return real_path == real_root
        or real_path:sub(1, #real_root + 1) == real_root .. "/"
end

local function is_rendercv_buffer()
    local buf = vim.fn.expand("%:p")
    if buf == "" then return false end
    return path_is_under(buf, CV_ROOT)
end

local function pdf_for_yaml(yaml)
    local stem = vim.fn.fnamemodify(yaml, ":t:r")
    return CV_ROOT .. "/rendercv_output/" .. stem .. ".pdf"
end

local function rendercv_preview_stop()
    if rendercv_watch_job then
        rendercv_stopping = true
        pcall(vim.fn.jobstop, rendercv_watch_job)
        rendercv_watch_job = nil
    end

    if zathura_job then
        pcall(vim.fn.jobstop, zathura_job)
        zathura_job = nil
    end
end

local function open_pdf_when_ready(pdf, attempts_left)
    if not rendercv_watch_job then return end

    if vim.fn.filereadable(pdf) == 1 then
        zathura_job = vim.fn.jobstart({ "zathura", pdf })
        if zathura_job <= 0 then
            zathura_job = nil
            vim.notify("RenderCV Preview: failed to open zathura", vim.log.levels.ERROR)
        end
        return
    end

    if attempts_left <= 0 then
        vim.notify("RenderCV Preview: PDF not found: " .. pdf, vim.log.levels.WARN)
        return
    end

    vim.defer_fn(function()
        open_pdf_when_ready(pdf, attempts_left - 1)
    end, 500)
end

local function rendercv_preview_toggle()
    if rendercv_watch_job then
        rendercv_preview_stop()
        vim.notify("RenderCV Preview: stopped", vim.log.levels.INFO)
        return
    end

    if not is_rendercv_buffer() then
        vim.notify("RenderCV Preview: not in " .. CV_ROOT, vim.log.levels.WARN)
        return
    end

    local yaml = vim.fn.expand("%:p")
    local pdf = pdf_for_yaml(yaml)
    local output = {}

    rendercv_watch_job = vim.fn.jobstart(
        { "rendercv", "render", yaml, "--watch", "--pdf-path", pdf },
        {
            cwd = CV_ROOT,
            stdout_buffered = false,
            stderr_buffered = false,
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
                local was_stopping = rendercv_stopping
                vim.schedule(function()
                    rendercv_watch_job = nil
                    rendercv_stopping = false
                    if code ~= 0 and not was_stopping then
                        vim.notify(
                            "RenderCV Preview: rendercv exited (" .. code .. ")\n"
                                .. table.concat(output, "\n"),
                            vim.log.levels.ERROR
                        )
                    end
                end)
            end,
        }
    )

    if rendercv_watch_job <= 0 then
        rendercv_watch_job = nil
        vim.notify("RenderCV Preview: failed to start rendercv", vim.log.levels.ERROR)
        return
    end

    vim.notify("RenderCV Preview: started", vim.log.levels.INFO)
    open_pdf_when_ready(pdf, 20)
end

vim.api.nvim_create_user_command("RenderCVPreviewToggle", rendercv_preview_toggle, {})

vim.api.nvim_create_autocmd("FileType", {
    group = vim.api.nvim_create_augroup("lang-rendercv-yaml", { clear = true }),
    pattern = { "yaml", "yml" },
    callback = function()
        if not is_rendercv_buffer() then return end

        vim.opt_local.makeprg = "rendercv render %"

        vim.keymap.set("n", "<leader>tp", "<Cmd>RenderCVPreviewToggle<CR>",
            { buffer = 0, silent = true, desc = "Toggle Preview" })

        local ok, wk = pcall(require, "which-key")
        if ok then
            wk.add({ "<leader>tp", desc = "Toggle Preview", buffer = 0 })
        end
    end,
})

vim.api.nvim_create_autocmd("VimLeavePre", {
    group = vim.api.nvim_create_augroup("lang-rendercv-cleanup", { clear = true }),
    callback = rendercv_preview_stop,
})

return {}
