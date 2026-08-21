-- zeta: Typst note-graph language server (Zettelkasten interconnect over ~/research).
-- Coexists with tinymist on `.typ`: tinymist owns compile/diagnostics/completion,
-- zeta owns #link navigation, backlinks, note search, and the live graph view.
return {
    cmd = { "zeta" },
    filetypes = { "typst" },
    -- Anchor the note graph at ~/research (same markers as tinymist) so zeta scans
    -- every .typ under it — idea-notes in notes/ and each paper's notes.typ.
    root_markers = {
        "typst.toml",
        ".git",
    },
    init_options = {
        -- Capture #link("x") and #link("x")[display] (Typst parses the
        -- display form as a nested call). @target is the link path; headings
        -- supply node titles.
        --
        -- Also capture wrapper functions defined in /templates/note.typ that
        -- keep the target as their first string arg — currently just
        -- back-link. Add each with its own #eq? pattern pair (raw + nested)
        -- rather than #any-of? — the latter parses in tree-sitter but
        -- smacker/go-tree-sitter's FilterPredicates ignores unknown
        -- operators, degrading the query to "match every call" and
        -- flooding the graph with garbage edges.
        query = [[
            (code (call item: (ident) @link (#eq? @link "link") (group (string) @target )))
            (code (call item: (call item: (ident) @link (#eq? @link "link") (group (string) @target ))))
            (code (call item: (ident) @link (#eq? @link "back-link") (group (string) @target )))
            (code (call item: (call item: (ident) @link (#eq? @link "back-link") (group (string) @target ))))
            (heading (text) @title)
            (heading (label) @taxon)
        ]],
        select_regex = '^"(.*)"$',
        file_extensions = { ".typ" },
        default_extension = ".typ",
        -- Node label = the heading title only (the <label> taxon carries angle
        -- brackets and, on a paper note, duplicates the citation key).
        title_template = "%s",
        title_substitutions = { "title" },
    },
    -- Follow-link (gd), backlinks (gr) and note search (gS) come free from the
    -- central LspAttach maps (fzf-lua aggregates across clients: on a #link only
    -- zeta answers, on a symbol only tinymist does). Only the graph view needs a
    -- binding, since it is a workspace command rather than a standard LSP method.
    on_attach = function(client, bufnr)
        vim.api.nvim_buf_create_user_command(bufnr, "ZetaGraph", function()
            -- Starts an in-process HTTP+WebSocket server and pushes its URL back
            -- via window/showDocument{External}; nvim opens it in the browser
            -- (xdg-open -> vimb). The graph then live-updates as you edit.
            client:request("workspace/executeCommand",
                { command = "graph", arguments = {} }, nil, bufnr)
        end, { desc = "zeta: open the live note graph" })

        vim.keymap.set("n", "<leader>ng", "<Cmd>ZetaGraph<CR>",
            { buffer = bufnr, desc = "Note graph" })
        local ok_wk, wk = pcall(require, "which-key")
        if ok_wk then
            wk.add({ "<leader>ng", desc = "Note graph", buffer = bufnr })
        end
    end,
}
