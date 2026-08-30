local M = {}

local state = {
    job_id = nil,
    auto_show_output = true,
    output_buf = nil,
    output_win = nil,
}

local function is_valid_win(win)
    return win and vim.api.nvim_win_is_valid(win)
end

local function is_valid_buf(buf)
    return buf and vim.api.nvim_buf_is_valid(buf)
end

local function ensure_output_buf()
    if not is_valid_buf(state.output_buf) then
        state.output_buf = vim.api.nvim_create_buf(false, true)
        vim.api.nvim_buf_set_name(state.output_buf, "Build Output")
        vim.bo[state.output_buf].buftype = "nofile"
        vim.bo[state.output_buf].bufhidden = "hide"
        vim.bo[state.output_buf].swapfile = false
        vim.bo[state.output_buf].filetype = "make"
    end
    return state.output_buf
end

local function show_output()
    local buf = ensure_output_buf()
    if is_valid_win(state.output_win) then
        return state.output_win
    end

    local current_win = vim.api.nvim_get_current_win()
    vim.cmd("botright 12split")
    state.output_win = vim.api.nvim_get_current_win()
    vim.api.nvim_win_set_buf(state.output_win, buf)
    vim.wo[state.output_win].wrap = false
    vim.wo[state.output_win].number = false
    vim.wo[state.output_win].relativenumber = false
    vim.wo[state.output_win].signcolumn = "no"

    if is_valid_win(current_win) then
        vim.api.nvim_set_current_win(current_win)
    end

    return state.output_win
end

local function append_lines(data)
    if not data then
        return
    end

    local buf = ensure_output_buf()
    local lines = {}
    for _, line in ipairs(data) do
        if line ~= "" then
            table.insert(lines, line)
        end
    end
    if #lines == 0 then
        return
    end

    vim.api.nvim_buf_set_lines(buf, -1, -1, false, lines)

    if is_valid_win(state.output_win) then
        local line_count = vim.api.nvim_buf_line_count(buf)
        vim.api.nvim_win_set_cursor(state.output_win, { line_count, 0 })
    end
end

local function make_cwd(makeprg)
    local quoted = makeprg:match("%-%-justfile%s+['\"]([^'\"]+)['\"]")
    local bare = makeprg:match("%-%-justfile%s+(%S+)")
    local justfile = quoted or bare
    if justfile then
        return vim.fn.fnamemodify(justfile, ":p:h")
    end
    return vim.fn.getcwd()
end

local function valid_qf_count()
    local valid = 0
    for _, e in ipairs(vim.fn.getqflist()) do
        if e.valid == 1 and e.bufnr and e.bufnr > 0 then
            valid = valid + 1
        end
    end
    return valid
end

function M.make(args)
    args = args or ""

    if state.job_id then
        vim.notify("AsyncMake: job already running", vim.log.levels.WARN)
        if state.auto_show_output then
            show_output()
        end
        return
    end

    local winnr = vim.fn.win_getid()
    local bufnr = vim.api.nvim_win_get_buf(winnr)
    local makeprg = vim.bo[bufnr].makeprg
    if not makeprg or makeprg == "" then
        vim.notify("AsyncMake: makeprg is empty", vim.log.levels.WARN)
        return
    end

    local cmd = makeprg
    if makeprg:find("%%") then
        local ok, expanded = pcall(vim.fn.expandcmd, makeprg)
        if ok and expanded and expanded ~= "" then
            cmd = expanded
        end
    end
    if args ~= "" then
        cmd = cmd .. " " .. args
    end

    local cwd = make_cwd(makeprg)
    local efm = vim.bo[bufnr].errorformat
    local output_lines = {}
    local buf = ensure_output_buf()
    vim.api.nvim_buf_set_lines(buf, 0, -1, false, {
        "$ " .. cmd,
        "",
    })

    if state.auto_show_output then
        show_output()
    end

    vim.notify("AsyncMake: started " .. cmd, vim.log.levels.INFO, { title = "make" })

    local function on_output(_, data, _)
        if not data then
            return
        end
        for _, line in ipairs(data) do
            if line ~= "" then
                table.insert(output_lines, line)
            end
        end
        vim.schedule(function()
            append_lines(data)
        end)
    end

    state.job_id = vim.fn.jobstart({ vim.o.shell, vim.o.shellcmdflag, cmd }, {
        cwd = cwd,
        stdout_buffered = false,
        stderr_buffered = false,
        on_stdout = on_output,
        on_stderr = on_output,
        on_exit = function(_, exit_code, _)
            vim.schedule(function()
                state.job_id = nil
                append_lines({ "", "[AsyncMake exited with code " .. exit_code .. "]" })

                local old_cwd = vim.fn.getcwd()
                if cwd and cwd ~= "" then
                    vim.fn.chdir(cwd)
                end
                vim.fn.setqflist({}, " ", {
                    title = cmd,
                    lines = output_lines,
                    efm = efm,
                })
                if old_cwd and old_cwd ~= "" then
                    vim.fn.chdir(old_cwd)
                end

                vim.api.nvim_exec_autocmds("QuickFixCmdPost", { pattern = "make" })

                if exit_code == 0 then
                    vim.notify("AsyncMake: finished successfully", vim.log.levels.INFO, { title = "make" })
                else
                    local level = valid_qf_count() > 0 and vim.log.levels.ERROR or vim.log.levels.WARN
                    vim.notify("AsyncMake: exited with code " .. exit_code, level, { title = "make" })
                end
            end)
        end,
    })

    if state.job_id <= 0 then
        state.job_id = nil
        vim.notify("AsyncMake: failed to start " .. cmd, vim.log.levels.ERROR)
    end
end

function M.toggle_output()
    state.auto_show_output = not state.auto_show_output
    local status = state.auto_show_output and "enabled" or "disabled"

    if state.auto_show_output then
        show_output()
    elseif is_valid_win(state.output_win) then
        vim.api.nvim_win_close(state.output_win, true)
        state.output_win = nil
    end

    vim.notify("Build output auto-show " .. status, vim.log.levels.INFO)
end

function M.show_output()
    show_output()
end

return M
