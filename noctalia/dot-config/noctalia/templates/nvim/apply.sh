#!/usr/bin/env bash
# Noctalia post_hook for [theme.templates.user.nvim].
# Signal every running nvim to reload the palette; the SIGUSR1 handler
# lives in ~/.config/nvim/lua/plugins/colorscheme.lua and re-reads
# ~/.cache/noctalia/nvim-palette.lua via loadfile (no require cache).
pkill -SIGUSR1 -x nvim || true
