-- Optional local overrides at ~/.config/yazi/local.lua (untracked).
-- Used to keep private identifiers (e.g. GPG key_grip) off git.
local locals = {}
local ok, mod = pcall(dofile, os.getenv("HOME") .. "/.config/yazi/local.lua")
if ok and type(mod) == "table" then
    locals = mod
end

require("gvfs"):setup({
    password_vault = "pass",
    key_grip = locals.key_grip,
    save_password_autoconfirm = true,
})
require("sshfs"):setup()
require("archivemount"):setup()
