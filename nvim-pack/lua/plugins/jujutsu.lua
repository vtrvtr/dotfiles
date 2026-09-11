return {
    "mistweaverco/jujutsu.nvim",
    lazy = true,
    -- optional deps:
    -- dependencies = { "sindrets/diffview.nvim" },
    keys = {
        {
            "<leader>gg",
            function()
                require(
                    "jujutsu"
                ).open()
            end,
            desc = "Jujutsu"
        }
    },
    opts = {} -- passed to setup()
}