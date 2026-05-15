-- Plugin: numToStr/Comment.nvim
-- Installed via store.nvim

return {
    "numToStr/Comment.nvim",
    keys = {
        { "gc", mode = { "n", "x" }, desc = "Comment toggle linewise" },
        { "gb", mode = { "n", "x" }, desc = "Comment toggle blockwise" },
    },
    opts = {}
}