-- TODO: Rewatch Mr Jakob video on project with fzf-lua, auto-complete, and keymappings. He updates project to use fzf-lua
--local project_nvim = require("project_nvim")
--vim.keymap.set("n", "<leader>p", function()
--	project_nvim.get_recent_projects()
--end, { desc = "[P]roject" })
--
return {
    "folke/which-key.nvim",
    event = "VeryLazy",
    opts = {
        preset = "modern",
        delay = 0,
        icons = {
            mappings = true, -- Set to true because we have nerd fonts
            keys = {},       -- Set to empty table because we have nerd fonts
        },
        spec = {
            -- GoTo
            { "<leader>g", group = "[G]o To", mode = { "n", "v" } },

            -- Code Actions
            { "<leader>c", group = "[C]ode",  mode = { "n", "v" } },
            -- TODO: map <leader>cc to [c]ode->toggle [c]omment selection
            {
                "<leader>cf",
                function()
                    require("conform").format()
                end,
                desc = "[C]ode [F]ormat",
                mode = { "n", "v" },
            },
            { "<leader>d", group = "Debug | [D]atabase", mode = { "n", "v" } },

            -- Buffers group
            { "<leader>b", group = "Buffers",            mode = { "n", "v" } },

            {
                "<leader>bn",
                ":bnext<CR>",
                desc = "Next buffer",
                mode = { "n" },
                icon = { icon = "", hl = "MiniIconsArrowRight", color = "green" },
            },
            {
                "<leader>bp",
                ":bprevious<CR>",
                desc = "Previous buffer",
                mode = { "n" },
                icon = { icon = "", hl = "MiniIconsArrowLeft", color = "yellow" },
            },
            {
                "<leader>bd",
                ":bdelete<CR>",
                desc = "Delete buffer",
                mode = { "n" },
                icon = { icon = "", hl = "MiniIconsClose", color = "red" },
            },


            -- { "<leader>o", group = "[O]bsidian", mode = { "n" } },

            -- Project Management
            -- { "<leader>p", group = "[P]rojects", mode = { "n" } },

            -- AI Code Companion
            -- { "<leader>a", group = "[A]I Code Companion", mode = { "n", "v" } },
            -- { "<leader>at", "<cmd>CodeCompanion Toggle<cr>", desc = "[A]I  [t]oggle chat", mode = { "n", "v" } },
            -- { "<leader>ap", "<cmd>CodeCompanion<cr>", desc = "[A]I  [P]rompt", mode = { "n", "v" } },
            -- { "<leader>aa", "<cmd>CodeCompanionActions<cr>", desc = "[A]I [A]ctions", mode = { "n", "v" } },
            -- { "<leader>ac", "<cmd>CodeCompanionChat<cr>", desc = "[A]I [C]hat", mode = { "n", "v" } },
            -- { "<leader>ax", "<cmd>CodeCompanionCmd<cr>", desc = "[A]I a[x]ion", mode = { "n", "v" } },

            -- Toggle
            { "<leader>t", group = "Toggle", mode = { "n" } },
            {
                "<leader>tl",
                function()
                    vim.diagnostic.open_float()
                end,
                desc = "Open Diagnostics",
                mode = { "n" },
            },

            -- Find -- Mostly defined in fzf-lua plugin
            -- TODO: Move FZF-LUA keymaps here
            { "<leader>f", group = "Find",   mode = { "n" } },

            -- Make — dispatches through the project's justfile (see
            -- lang/swift.lua). Targets: debug/release/run-debug/run-release/
            -- test/clean; JustfileInit creates a starter justfile in Swift
            -- PM projects.
            { "<leader>m",   group = "Make",                                                       mode = { "n" } },
            { "<leader>mi",  "<Cmd>JustfileInit<CR>",     desc = "[I]nit justfile",                mode = { "n" } },
            { "<leader>mc",  "<Cmd>make clean<CR>",       desc = "[C]lean",                        mode = { "n" } },
            { "<leader>mb",  group = "Build",                                                      mode = { "n" } },
            { "<leader>mbd", "<Cmd>make debug<CR>",       desc = "Build [D]ebug",                  mode = { "n" } },
            { "<leader>mbr", "<Cmd>make release<CR>",     desc = "Build [R]elease",                mode = { "n" } },
            { "<leader>mr",  group = "Run",                                                        mode = { "n" } },
            { "<leader>mrd", "<Cmd>make run-debug<CR>",   desc = "Run [D]ebug",                    mode = { "n" } },
            { "<leader>mrr", "<Cmd>make run-release<CR>", desc = "Run [R]elease",                  mode = { "n" } },
            { "<leader>mrt", "<Cmd>make test<CR>",        desc = "Run [T]ests",                    mode = { "n" } },

            -- { "<leader>s",   group = "Strudel",           mode = { "n" } },

            -- :Noice or :Noice history shows the message history:Noice last shows the last message in a popup
            -- :Noice dismiss dismiss all visible messages
            -- :Noice errors shows the error messages in a split. Last errors on top
            -- :Noice disable disables Noice
            -- :Noice enable enables Noice
            -- :Noice stats shows debugging stats

            -- MadMachine SwiftIO
            -- { "<leader>m", group = "[M]adMachine", mode = { "n" } },

            -- TODO Keymaps
            -- { "<leader>ft", "<CMD>TodoFzfLua<CR>", desc = "[T]ODOs", mode = { "n" } },
            -- {
            -- 	"]t",
            -- 	function()
            -- 		require("todo-comments").jump_next()
            -- 	end,
            -- 	desc = "Next todo comment",
            -- 	mode = { "n" },
            -- },
            -- {
            -- 	"[t",
            -- 	function()
            -- 		require("todo-comments").jump_prev()
            -- 	end,
            -- 	desc = "Previous todo comment",
            -- 	mode = { "n" },
            -- },
        },
    },
    keys = {
        {
            "<leader>xp",
            function()
                -- 1. Create a notification to show we've started
                local status = vim.notify("Periphery: Scanning project...", vim.log.levels.INFO, {
                    title = "Periphery",
                    timeout = false, -- Keep it open until we manually close it
                })

                local lines = {}

                -- 2. Start the background job
                vim.fn.jobstart("periphery scan --format xcode --no-superfluous-ignore-comments", {
                    stdout_buffered = true,
                    on_stdout = function(_, data)
                        if data then
                            for _, line in ipairs(data) do
                                if line ~= "" then table.insert(lines, line) end
                            end
                        end
                    end,
                    on_exit = function(_, exit_code)
                        -- 3. Dismiss the "Scanning" notification
                        -- If you use nvim-notify, we "update" the notification to make it vanish
                        vim.notify("Scan Complete", vim.log.levels.INFO, {
                            replace = status,
                            timeout = 3000, -- Dismiss after 3 seconds
                        })

                        if exit_code == 0 and #lines > 0 then
                            vim.fn.setqflist({}, " ", { title = "Periphery Scan", lines = lines })
                            vim.cmd("copen")
                        elseif exit_code == 0 then
                            vim.notify("Periphery: No unused code found!", vim.log.levels.INFO)
                        else
                            vim.notify("Periphery: Scan failed. Ensure you've built the project first.",
                                vim.log.levels.ERROR)
                        end
                    end,
                })
            end,
            desc = "Periphery: Scan Dead Code",
        },
        {
            "<leader>?",
            function()
                require("which-key").show({ global = false })
            end,
            desc = "Buffer Local Keymaps",
        },
        { "<leader>/",  ":normal gcc<CR><DOWN>", desc = "[/] Comment line",        mode = { "n" } },
        { "<Esc>",      "<cmd>nohlsearch<CR>",   desc = "Clear search highlights", mode = { "n" } },
        { "<leader>tm", "<cmd>Noice fzf<cr>",    desc = "Messages",                mode = { "n", "v" } },
        { "<leader>q",  ":qa<CR>",               desc = "Quit",                    mode = { "n" } },

        -- Buffer navigation with Tab / Shift-Tab (saves first if the current
        -- buffer is modified — avoids "no write since last change" prompts).
        {
            "<Tab>",
            function()
                if vim.bo.modifiable and not vim.bo.readonly and vim.bo.modified then
                    vim.cmd("write")
                end
                vim.cmd("bnext")
            end,
            desc = "Next buffer (save first)",
            mode = { "n" },
        },
        {
            "<S-Tab>",
            function()
                if vim.bo.modifiable and not vim.bo.readonly and vim.bo.modified then
                    vim.cmd("write")
                end
                vim.cmd("bprevious")
            end,
            desc = "Previous buffer (save first)",
            mode = { "n" },
        },

        -- Cmd-S save. Terminal must send <D-s> (Ghostty is configured to on
        -- this machine; other terminals will silently no-op).
        { "<D-s>", "<Cmd>write<CR>", desc = "Save", mode = { "n", "v", "i" } },

        -- Alt-b / Alt-r quick access for build/run debug. Global so they
        -- work from any buffer; the current buffer's makeprg decides what
        -- gets built (lang/swift.lua points swift buffers at their
        -- justfile, other filetypes fall back to whatever makeprg they've
        -- been assigned).
        { "<A-b>", "<Cmd>make debug<CR>",     desc = "Build (debug)", mode = { "n" } },
        { "<A-r>", "<Cmd>make run-debug<CR>", desc = "Run (debug)",   mode = { "n" } },

        -- icon = { icon = " ", hl = "MiniIconsClose", color = "purple" },
    },
}
