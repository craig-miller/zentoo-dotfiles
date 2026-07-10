return {
    "chomosuke/typst-preview.nvim",
    version = "1.*",
    ft = "typst",
    opts = {
        -- Reuse the tinymist + websocat binaries already on PATH — no
        -- plugin-managed downloads. tinymist comes from Mason (see
        -- mason.lua); websocat from net-misc/websocat.
        dependencies_bin = {
            tinymist = "tinymist",
            websocat = "websocat",
        },
        -- Open the preview in vimb (zentoo's browser).
        open_cmd = "vimb %s",
    },
}
