local o = vim.o
local g = vim.g

-- Set before loading lazy (This file is loaded before loading lazy)
g.mapleader = " "
g.maplocalleader = "\\"
g.have_nerd_font = true

-- Disable netrw we have alternatives
g.loaded_netrw = 1
g.loaded_netrwPlugin = 1

-- Add options here
vim.opt.listchars = { tab = "» ", trail = "·", nbsp = "␣" }
vim.opt.swapfile = false
vim.opt.winborder = "rounded"
vim.opt.foldmethod = "expr"
vim.opt.foldexpr = "v:lua.vim.treesitter.foldexpr()"
vim.opt.foldtext = ""
vim.opt.foldlevel = 99
vim.opt.foldlevelstart = 99
vim.opt.foldnestmax = 5
o.timeoutlen = 1000 -- Necessary for mini.surround to work.  Default is 300
o.laststatus = 3    -- views can only be fully collapsed with the global statusline
o.expandtab = true  -- Convert tabs to spaces
o.shiftwidth = 4    -- Amount to indent with << & >>
o.tabstop = 4       -- Spaces to show per tab char
o.softtabstop = 4   -- # Spaces to insert with tab
o.textwidth = 120
o.smarttab = true
o.smartindent = true
o.autoindent = true      -- Keep indentation from previous line
o.termguicolors = true   -- 24-bit color
o.number = true          -- Show line numbes
o.relativenumber = true  -- Show relative line numbers
o.splitbelow = true      -- Open splits below by default.  :terminal will open at bottom of screen
o.cursorlineopt = "both" -- to enable cursorline!
o.cursorcolumn = false   -- Show current column across all lines (distracting)
o.breakindent = true     -- Enabled break indent

o.undofile = true        -- Store undos between sessions

o.mouse = "a"            -- Mouse mode.  Resize splits, mouse selection, etc

o.showmode = false       -- Don't show mode since it's in our statusline

o.ignorecase = true      -- Case insensitive search
o.smartcase = true       -- If I type an uppercase letter, search case-sensitive
o.signcolumn = "yes"     -- Always show icon column that shows icons from builds, linters,
-- etc like warning triangle

o.updatetime = 250  -- Decrease update time
o.timeoutlen = 300  -- Decrease mapped sequence wait time

o.splitright = true -- new split window on right
o.splitbelow = true -- new split window below

-- Set how whitespace chars are shown
o.list = true

-- Preview substitutions live, as you type!
o.inccommand = "split"

-- Show which line your cursor is on
o.cursorline = true

-- Minimal number of screen lines to keep above and below the cursor.
o.scrolloff = 10
o.cmdheight = 0

-- if performing an operation that would fail due to unsaved changes in the buffer (like `:q`),
-- instead raise a dialog asking if you wish to save the current file(s)
-- See `:help 'confirm'`
o.confirm = true

------------------------------------------------------------------------------
-- GUI

o.guifont = "MonoLisa"

-- Fallback to SFMono so we get nice emoji.
-- Ghostty is setup similarly for terminal based nvim
o.guifont = "SFMono Nerd Font"
-- o.guifont = "Hack Nerd Font Mono:h17"
-- o.guifont = "Hack Nerd Font:h17"
-- o.guifont = "AnonymicePro Nerd Font:h17" -- text below applies for VimScript
-- o.guifont = "SFMono Nerd Font:h17" -- text below applies for VimScript

-- Allow clipboard copy paste in neovim
vim.opt.clipboard = "unnamed"

-- Neovide
-- if g.neovide then
-- g.neovide_text_gamma = 0.5
-- g.neovide_text_contrast = 0.5
g.neovide_scale_factor = 1.3

-- o.linespace = 10
-- vim.keymap.set("v", "<D-c>", '"+y') -- Copy
-- vim.keymap.set("n", "<D-v>", '"+P') -- Paste normal mode
-- vim.keymap.set("v", "<D-v>", '"+P') -- Paste visual mode

-- Doesn't work: vim.keymap.set("i", "<D-v>", '<ESC>l"+Pli') -- Paste insert mode
-- vim.keymap.set("c", "<D-v>", "<C-R>+") -- Paste command mode:  E.g. ":" commands.
-- vim.keymap.set("i", "<D-v>", "<C-R>+") -- Paste insert mode
-- vim.api.nvim_set_keymap("!", "<D-v>", "<C-R>+", { noremap = true, silent = true })
-- vim.api.nvim_set_keymap("t", "<D-v>", "<C-R>+", { noremap = true, silent = true })
-- vim.keymap.set("n", "<D-s>", ":w<CR>") -- Save

-- Put any neovide options here
-- g.neovide_opacity = 0.9
-- g.neovide_cursor_trail_size = .5
--
-- g.neovide_position_animation_length = 0
-- g.neovide_cursor_animation_length = 0.00
-- g.neovide_cursor_trail_size = 0
-- g.neovide_cursor_animate_in_insert_mode = false
-- g.neovide_cursor_animate_command_line = false
-- g.neovide_scroll_animation_far_lines = 0
-- g.neovide_scroll_animation_length = 0.00
-- g.neovide_disable_all_animations = true
-- end


-- Easily switch between buffers with tab
vim.keymap.set('n', '<tab>', function()
    if vim.bo.modifiable and not vim.bo.readonly and vim.bo.modified then
        vim.cmd('write')
    end
    vim.cmd('bnext')
end, { silent = true, noremap = true })

vim.keymap.set('n', '<S-Tab>', function()
    if vim.bo.modifiable and not vim.bo.readonly and vim.bo.modified then
        vim.cmd('write')
    end
    vim.cmd('bprevious')
end, { silent = true, noremap = true })

-- Easily switch between buffers with leader-n, p, and delete with leader d
-- vim.api.nvim_set_keymap("", "<leader>n", ":bnext<cr>", { noremap = true, silent = true })
-- vim.api.nvim_set_keymap("", "<leader>p", ":bprevious<cr>", { noremap = true, silent = true })
-- vim.api.nvim_set_keymap("", "<leader>d", ":bdelete<cr>", { noremap = true, silent = true })


-- Easy open terminal
-- vim.api.nvim_set_keymap("n", "<leader>tt", ":botright terminal<CR>", { noremap = true, silent = true })

-- Use ctrl-[ to jump back from a tag instead of ctrl-t
-- vim.keymap.set("n", "<C-[>", "<C-t>", { silent = true })
-- Use ctrl-n to go down 1/2 page instead of ctrl-d
-- vim.keymap.set("n", "<C-n>", "<C-d>", { silent = true })
-- vim.keymap.set("n", "<D-q>", "<Cmd>qa<CR>", { noremap = true, silent = true }) -- Doesn't work in ghostty, as ghostty will try and quit.
vim.keymap.set({ "n", "v", "i" }, "<D-s>", "<Cmd>write<CR>", { desc = "Save", noremap = true, silent = true })
