-- Initialize build mode global variable (default to debug)
vim.g.swift_build_mode = vim.g.swift_build_mode or "debug"
vim.g.swift_is_package = vim.g.swift_is_package or false
vim.g.swift_package_dir = nil

-- User command to select and load the correct compiler
vim.api.nvim_create_user_command("SwiftSetup", function()
    local function find_package_swift()
        local path = vim.fn.expand('%:p:h')
        while path ~= "/" do
            if vim.fn.filereadable(path .. "/Package.swift") == 1 then
                -- print(path)
                return path
            end
            path = vim.fn.fnamemodify(path, ":h")
        end
        return nil
    end

    local package_dir = find_package_swift()
    local build_mode = vim.g.swift_build_mode or "release"

    if package_dir then
        vim.g.swift_is_package = true
        vim.g.swift_package_dir = package_dir
        if build_mode == "debug" then
            print("Debug Swift PM Build")
            vim.cmd("compiler swiftpm_debug")
        else
            -- print("Release Swift PM build")
            vim.cmd("compiler swiftpm")
        end
    else
        vim.g.swift_is_package = false
        vim.g.swift_package_dir = nil
        if build_mode == "debug" then
            -- print("Debug swift compile")
            vim.cmd("compiler swift_debug")
        else
            -- print("Release swift compile")
            vim.cmd("compiler swift")
        end
    end
end, {})

-- Toggle command updates mode and calls above command to change compiler
vim.api.nvim_create_user_command("SwiftBuildToggle", function()
    if vim.g.swift_build_mode == "release" then
        vim.g.swift_build_mode = "debug"
        print("Swift build mode set to DEBUG")
    else
        vim.g.swift_build_mode = "release"
        print("Swift build mode set to RELEASE")
    end
    vim.cmd("SwiftSetup")
end, {})
