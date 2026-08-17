return {
    "chomosuke/typst-preview.nvim",
    version = "1.*",
    ft = "typst",
    opts = {
        -- Reuse the tinymist + websocat binaries already on PATH — no
        -- plugin-managed downloads. tinymist comes from Mason (see
        -- mason.lua); websocat from net-misc/websocat.
        dependencies_bin = {
            tinymist = "tinymist",
            websocat = "websocat",
        },
        -- Open the preview in vimb. Query-param marker lets a vimb
        -- LoadFinished autocmd auto-engage passthrough on preview pages
        -- (dark-mode toggle + typst-preview's JS keybinds are inside the page).
        open_cmd = "vimb %s?zentoo-typst-preview=1",
    },
    config = function(_, opts)
        require("typst-preview").setup(opts)

        -- Downstream monkey-patch: close the browser instance when the
        -- preview server is stopped. Upstream utils.visit() fires
        -- jobstart on the browser and discards the returned job id, and
        -- upstream servers.remove() only kills the tinymist server — the
        -- browser tab lingers on a stale render forever.
        --
        -- Two subtleties that bit an earlier version of this patch:
        --   1. Patch `typst-preview.servers`, NOT `.servers.manager`.
        --      The aggregator copies manager.remove by REFERENCE at
        --      require time (`M.remove = manager.remove`), so
        --      commands.lua's `servers.remove` keeps pointing at the
        --      original even after `manager.remove` is replaced.
        --   2. Spawn the browser via a table cmd, NOT a string. A string
        --      cmd goes through `sh -c` — jobstop then kills the shell
        --      but vimb (a forked child) survives. Table form execs
        --      vimb directly so the job IS vimb and jobstop terminates
        --      the actual browser process.
        local utils = require("typst-preview.utils")
        local servers = require("typst-preview.servers")

        -- {link -> jobid}. Different toggle-ons get different ports (by
        -- design — one server per doc), so link is a stable key per
        -- server, and each entry is removed when its owning server is
        -- torn down.
        local browser_jobs = {}

        -- Parse open_cmd ("vimb %s") into an argv list, substituting %s
        -- with the URL. Simple whitespace split — sufficient for the
        -- browser-launch invocations we ship; complex quoting would
        -- need shellwords parsing.
        local function build_argv(url)
            local argv = {}
            for word in string.gmatch(opts.open_cmd, "%S+") do
                if word == "%s" then
                    table.insert(argv, url)
                else
                    table.insert(argv, (word:gsub("%%s", url)))
                end
            end
            return argv
        end

        utils.visit = function(link)
            local url = "http://" .. link
            local jobid = vim.fn.jobstart(build_argv(url), {
                on_stderr = function(_, data)
                    local msg = table.concat(data or {}, "\n")
                    if msg ~= "" then
                        print("typst-preview opening link failed: " .. msg)
                    end
                end,
            })
            if jobid and jobid > 0 then
                browser_jobs[link] = jobid
            end
        end

        local orig_remove = servers.remove
        servers.remove = function(path)
            -- Snapshot links before removal drops servers[path].
            local sers = servers.get(path)
            local links = {}
            if sers then
                for _, ser in pairs(sers) do
                    if ser.link then
                        table.insert(links, ser.link)
                    end
                end
            end

            local removed = orig_remove(path)

            for _, link in ipairs(links) do
                local jobid = browser_jobs[link]
                if jobid then
                    pcall(vim.fn.jobstop, jobid)
                    browser_jobs[link] = nil
                end
            end

            return removed
        end
    end,
}
