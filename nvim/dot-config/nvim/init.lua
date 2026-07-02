-- Listen on a per-PID socket so the colorscheme switcher
-- (~/.config/tinted-theming/extras/nvim-rpc.sh) can flip themes in live
-- instances without a restart.
pcall(vim.fn.serverstart, "/tmp/nvim-" .. vim.fn.getpid() .. ".sock")

-- Make sure to set `mapleader` and `maplocalleader` option before loading Lazy
-- So, load config.options before Lazy.
require("config.options")
require("core.lazy")
require("core.lsp")
require("config.autocmds")
require("config.usercmds")
require("config.lang")
