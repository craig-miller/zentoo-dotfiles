-- Local sioyek integration for the ~/research Zettelkasten workflow.
--
-- Two entry points bound in plugins/local-sioyek.lua:
--   <leader>ph — pick a highlight from sioyek's shared.db, insert as Typst
--                #quote(attribution: [@ref[p. N]])[text] + UUID marker.
--   <leader>pj — from a UUID marker (or nearby), jump the current sioyek
--                instance to that highlight; fall back to opening the paper
--                if no marker under cursor.
--
-- Replaces jbuck95/nvim-sioyek-highlights (was retired because its picker
-- dropped uuid/coords from the query, its format_function received only
-- text, and its fuzzy-text jump was incompatible with our Typst-wrapped
-- quotes). See [[project_research_pkm_setup]] + [[feedback_sioyek_config_quirks]].

local M = {}

function M.pick_highlights()
    require("local.sioyek.picker").pick()
end

function M.jump_to_source()
    require("local.sioyek.jump").jump()
end

return M
