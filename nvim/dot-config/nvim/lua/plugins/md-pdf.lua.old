return {
    'arminveres/md-pdf.nvim',
    branch = 'main', -- you can assume that main is somewhat stable until releases will be made
    lazy = true,
    keys = {
        {
            "<leader>p",
            function() require("md-pdf").convert_md_to_pdf() end,
            desc = "Markdown preview",
        },
    },
    ---@type md-pdf.config
    opts = {
        --- Set margins around document
        margins = "1.5cm",
        -- tango, pygments are quite nice for white on white
        highlight = "tango",
        -- Generate a table of contents, on by default
        toc = true,
        -- Render a dedicated title page (and keep ToC on a separate page)
        title_page = false,
        -- Define a custom preview command, enabling hooks and other custom logic
        -- preview_cmd = function() return '/System/Applications/Preview' end,
        -- if true, then the markdown file is continuously converted on each write, even if the
        -- file viewer closed, e.g., Firefox is "closed" once the document is opened in it.
        ignore_viewer_state = false,
        -- Specify font, `nil` uses the default font of the theme
        fonts = nil,
        -- or, where all or only some options can be specified. NOTE: those that are `nil` can be left
        -- out completely
        -- fonts = {
        --     main_font = nil,
        --     sans_font = "DejaVuSans",
        --     mono_font = "IosevkaTerm Nerd Font Mono",
        --     math_font = nil,
        -- },
        -- Custom options passed to `pandoc` CLI call, can be ignored for setup
        pandoc_user_args = {
            "--from=markdown+wikilinks_title_after_pipe",
            "--citeproc",
            "--resource-path=.:/Users/craig/bibtex-files:/Users/craig/bibtex-files/csl",
            "--bibliography=ZoteroReferences.bib",
            "--csl=springer-basic-brackets.csl",
        },

        -- or
        -- pandoc_user_args = {
        --     -- short
        --     "-V KEY[:VALUE]",
        --     -- long options
        --     "--standalone=[true|false]",
        -- },
        --- Path to output. Needs to be always relative, e.g.: "./", "../", "./out" or simply "out", but
        --- not absolute e.g.: "/"!
        output_path = "./",
        -- PDF converter engine
        -- pdf_engine = "pdflatex",
    },
}
