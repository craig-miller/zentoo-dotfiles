-- Rendered by Noctalia [theme.templates.user.nvim] into
-- ~/.cache/noctalia/nvim-palette.lua on every palette apply.  Consumed
-- by ~/.config/nvim/lua/plugins/colorscheme.lua as catppuccin's
-- color_overrides.mocha table.  Do NOT hand-edit — regenerated on
-- every wallpaper change / dark-light flip.
--
-- Surface + text (crust..text): mapped from M3 semantic roles so the
--   surface luminance ramp stays coherent across palettes.  The
--   overlay2/subtext0 and subtext1/text pairs collide because M3
--   provides one on_surface_variant + one on_surface — catppuccin
--   distinguishes finer tiers than M3 semantics do.
--
-- Accents (rosewater..lavender): mapped from noctalia's terminal_*
--   16-ANSI intermediate.  With a builtin palette selected (catppuccin
--   etc.), these carry the palette's real accent values.  With
--   source=wallpaper, they collapse to whatever hues M3 tonal-spot
--   extracted from the image.

return {
    -- Surface / text (M3 semantic ramp)
    crust    = "{{colors.surface_dim.default.hex}}",
    mantle   = "{{colors.surface_container_lowest.default.hex}}",
    base     = "{{colors.surface.default.hex}}",
    surface0 = "{{colors.surface_container.default.hex}}",
    surface1 = "{{colors.surface_container_high.default.hex}}",
    surface2 = "{{colors.surface_container_highest.default.hex}}",
    overlay0 = "{{colors.surface_bright.default.hex}}",
    overlay1 = "{{colors.outline.default.hex}}",
    overlay2 = "{{colors.on_surface_variant.default.hex}}",
    subtext0 = "{{colors.on_surface_variant.default.hex}}",
    subtext1 = "{{colors.on_surface.default.hex}}",
    text     = "{{colors.on_surface.default.hex}}",

    -- Accents (terminal_* ANSI intermediate)
    rosewater = "{{colors.terminal_bright_yellow.default.hex}}",
    flamingo  = "{{colors.terminal_bright_red.default.hex}}",
    pink      = "{{colors.terminal_bright_magenta.default.hex}}",
    mauve     = "{{colors.terminal_normal_magenta.default.hex}}",
    red       = "{{colors.terminal_normal_red.default.hex}}",
    maroon    = "{{colors.terminal_bright_red.default.hex}}",
    peach     = "{{colors.terminal_bright_yellow.default.hex}}",
    yellow    = "{{colors.terminal_normal_yellow.default.hex}}",
    green     = "{{colors.terminal_normal_green.default.hex}}",
    teal      = "{{colors.terminal_normal_cyan.default.hex}}",
    sky       = "{{colors.terminal_bright_cyan.default.hex}}",
    sapphire  = "{{colors.terminal_bright_blue.default.hex}}",
    blue      = "{{colors.terminal_normal_blue.default.hex}}",
    lavender  = "{{colors.terminal_bright_magenta.default.hex}}",
}
