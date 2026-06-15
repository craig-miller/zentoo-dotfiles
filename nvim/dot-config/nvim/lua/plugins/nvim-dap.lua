return {
    "mfussenegger/nvim-dap",
    dependencies = {
        -- UI
        "theHamsta/nvim-dap-virtual-text",
        "rcarriga/nvim-dap-ui", -- Added dap-ui
        -- Adapter for CodeLLDB
        "julianolf/nvim-dap-lldb",
        -- Add xcodebuild dependency
        -- "wojciech-kulik/xcodebuild.nvim",
    },
    keys = {
        -- Toggle breakpoint with <leader>b
        { "<leader>db", function() require("dap").toggle_breakpoint() end, desc = "Toggle Breakpoint" },
        -- Run last debug session with <leader>dr
        { "<leader>dr", function() require("dap").run_last() end,          desc = "Run Last" },
        -- Continue debugging with <leader>dc
        { "<leader>dc", function() require("dap").continue() end,          desc = "Continue" },
        -- Run to cursor line with <leader>dl
        { "<leader>dl", function() require("dap").run_to_cursor() end,     desc = "Run to cursor line" },
        -- Step Over with <leader>do
        { "<leader>do", function() require("dap").step_over() end,         desc = "Step Over" },
        -- Step Into with <leader>di
        { "<leader>di", function() require("dap").step_into() end,         desc = "Step Into" },
        -- Step Out with <leader>du
        { "<leader>du", function() require("dap").step_out() end,          desc = "Step Out" },
        -- Quit debugging with <leader>dq
        {
            "<leader>dq",
            function()
                require("dap").terminate()
                require("dapui").close()
            end,
            desc = "[D]ebug [Q]uit"
        },

        -- Add xcodebuild key mappings
        -- * { "<leader>dR", function() require('xcodebuild.integrations.dap').build_and_debug() end,   desc = "Xcode Build & Debug" },
        -- Following is just an example line.  Don't include in final keys definition
        -- { "<leader>dR", "<cmd>XcodebuildSetup<cr>",          desc = "Xcodebuild Setup",                   mode = { "n" } },

        -- { "<leader>xxdb", function() require('xcodebuild.integrations.dap').debug_without_build() end,       desc = "Debug Without Building" },
        -- *{ "<leader>dt", function() require('xcodebuild.integrations.dap').debug_tests() end,       desc = "Xcode Debug Tests" },
        -- *{ "<leader>dT", function() require('xcodebuild.integrations.dap').debug_class_tests() end, desc = "Xcode Debug Class Tests" },
        -- { "<leader>xxtb", function() require('xcodebuild.integrations.dap').toggle_breakpoint() end,         desc = "Toggle Breakpoint" },
        -- "db", function() require('xcodebuild.integrations.dap').toggle_message_breakpoint() end, desc = "Toggle Message Breakpoint" },
        -- { "dq",           function() require('xcodebuild.integrations.dap').terminate_session() end,         desc = "Terminate Debugger" },

    },
    config = function()
        local dap = require("dap")
        -- local mason_registry = require("mason-registry")
        -- local xcodebuild = require("xcodebuild.integrations.dap")
        -- local codelldbPath = os.getenv("HOME") .. "/.swiftly/bin/sourcekit-lsp"

        -- Set up the DAP adapter for CodeLLDB.
        dap.adapters.codelldb = {
            type = 'server',
            port = "${port}",
            executable = {
                command = "codelldb", -- `mason.nvim` puts it in your path
                args = { "--port", "${port}" },
            }
        }

        -- Set up the debug configuration for Swift
        dap.configurations.swift = {
            {
                name = "Launch",
                type = "codelldb",
                request = "launch",
                program = function()
                    if vim.g.swift_is_package then
                        -- For Swift packages, use the package directory for build path
                        local package_dir = vim.g.swift_package_dir
                        local filename = vim.fn.fnamemodify(vim.fn.expand("%:p"), ":t:r")
                        -- Build path: package_dir/.build/debug/filename
                        return package_dir .. "/.build/debug/" .. filename
                    else
                        -- For standalone files, use the compiled file directly
                        return vim.fn.expand("%:p:r")
                    end
                end,
                args = {},
                cwd = function()
                    if vim.g.swift_is_package then
                        return vim.g.swift_package_dir or vim.fn.getcwd()
                    else
                        return "${workspaceFolder}"
                    end
                end,
                stopOnEntry = false,
            },
        }
    end,
}
