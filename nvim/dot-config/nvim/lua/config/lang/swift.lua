-- Swift buffer setup + module.
--   • Walks up from the buffer to find Package.swift.
--   • If found, sets makeprg to `just --justfile <pkg>/justfile` so :make
--     dispatches through the project's Justfile (see :JustfileInit to
--     create one).
--   • If not found, treats the buffer as a standalone .swift file:
--     makeprg = `swiftc % -o %:r`.
--   • Sets errorformat for Swift diagnostics.
--   • Also exposes g:swift_is_package / g:swift_package_dir for nvim-dap,
--     which reads them to locate the built binary.

vim.api.nvim_create_autocmd("FileType", {
    group = vim.api.nvim_create_augroup("lang-swift", { clear = true }),
    pattern = "swift",
    callback = function()
        vim.opt_local.errorformat = "%f:%l:%c: %m"

        local pkg = vim.fn.findfile("Package.swift", vim.fn.expand("%:p:h") .. ";")
        if pkg == "" then
            vim.opt_local.makeprg = "swiftc % -o %:r"
            vim.g.swift_is_package = false
            vim.g.swift_package_dir = nil
            return
        end

        local pkg_dir = vim.fn.fnamemodify(pkg, ":p:h")
        vim.g.swift_is_package = true
        vim.g.swift_package_dir = pkg_dir

        local justfile = pkg_dir .. "/justfile"
        vim.opt_local.makeprg = "just --justfile " .. vim.fn.shellescape(justfile)
    end,
})

local M = {}

function M.justfile_init()
    local pkg = vim.fn.findfile("Package.swift", vim.fn.expand("%:p:h") .. ";")
    if pkg == "" then
        vim.notify("JustfileInit (swift): no Package.swift found above this buffer",
            vim.log.levels.WARN)
        return
    end
    local pkg_dir = vim.fn.fnamemodify(pkg, ":p:h")
    local justfile = pkg_dir .. "/justfile"

    if vim.fn.filereadable(justfile) == 1 then
        vim.notify("JustfileInit: justfile already exists at " .. justfile,
            vim.log.levels.INFO)
        return
    end

    local bundler_toml = pkg_dir .. "/Bundler.toml"
    local is_bundler_app = vim.fn.filereadable(bundler_toml) == 1

    local lines
    if is_bundler_app then
        local app = vim.fn.fnamemodify(pkg_dir, ":t")
        local product = app
        for _, line in ipairs(vim.fn.readfile(bundler_toml)) do
            local parsed_app = line:match("^%s*%[apps%.([^%]]+)%]%s*$")
            if parsed_app then
                app = parsed_app
            end

            local parsed_product = line:match("^%s*product%s*=%s*['\"]([^'\"]+)['\"]%s*$")
            if parsed_product then
                product = parsed_product
            end
        end

        lines = {
            "app := \"" .. app .. "\"",
            "product := \"" .. product .. "\"",
            "host_os := os()",
            "platform := if host_os == \"linux\" { \"linux\" } else if host_os == \"macos\" { \"macOS\" } else { host_os }",
            "backend := if platform == \"linux\" { \"GtkBackend\" } else if platform == \"macOS\" { \"AppKitBackend\" } else if platform == \"iOS\" { \"UIKitBackend\" } else if platform == \"iOSSimulator\" { \"UIKitBackend\" } else if platform == \"android\" { \"AndroidBackend\" } else if platform == \"windows\" { \"WinUIBackend\" } else { \"DefaultBackend\" }",
            "device := \"\"",
            "simulator := \"\"",
            "bundler := if platform == \"linux\" { \"linuxGeneric\" } else if platform == \"macOS\" { \"darwinApp\" } else if platform == \"windows\" { \"windowsGeneric\" } else if platform == \"android\" { \"androidAPK\" } else { \"\" }",
            "device_arg := if device != \"\" { \"--device \" + quote(device) } else { \"\" }",
            "simulator_arg := if simulator != \"\" { \"--simulator \" + quote(simulator) } else { \"\" }",
            "bundler_arg := if bundler != \"\" { \"--bundler \" + bundler } else { \"\" }",
            "export SCUI_DEFAULT_BACKEND := backend",
            "",
            "debug:",
            "    swift build -c debug --product {{product}}",
            "",
            "release:",
            "    swift build -c release --product {{product}}",
            "",
            "run-debug:",
            "    swift-bundler run --platform {{platform}} -c debug {{device_arg}} {{simulator_arg}} {{app}}",
            "",
            "run-release:",
            "    swift-bundler run --platform {{platform}} -c release {{device_arg}} {{simulator_arg}} {{app}}",
            "",
            "bundle:",
            "    swift-bundler bundle --platform {{platform}} {{bundler_arg}} {{app}}",
            "",
            "test:",
            "    swift test",
            "",
            "clean:",
            "    swift package clean",
        }
    else
        lines = {
            "debug:",
            "    swift build -c debug",
            "",
            "release:",
            "    swift build -c release",
            "",
            "run-debug:",
            "    swift run -c debug",
            "",
            "run-release:",
            "    swift run -c release",
            "",
            "test:",
            "    swift test",
            "",
            "clean:",
            "    swift package clean",
        }
    end

    vim.fn.writefile(lines, justfile)
    if is_bundler_app then
        vim.notify("JustfileInit: created Swift Bundler justfile at " .. justfile,
            vim.log.levels.INFO)
    else
        vim.notify("JustfileInit: created " .. justfile, vim.log.levels.INFO)
    end
end

return M
