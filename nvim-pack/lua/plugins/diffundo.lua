return {
    "dsummersl/diffundo.nvim",
    dependencies = {
        "tpope/vim-repeat"
    },
    config = function()
        vim.keymap.set(
            "n",
            "<leader>uu",
            ":Diffundo earlier<cr>",
            {
                desc = "Diffundo earlier"
            }
        )
        vim.keymap.set(
            "n",
            "<leader>ul",
            ":Diffundo later<cr>",
            {
                desc = "Diffundo later"
            }
        )
        vim.keymap.set(
            "n",
            "<leader>uU",
            ":Diffundo earlier 1f<cr>",
            {
                desc = "Diffundo earlier 1f (write)"
            }
        )
        vim.keymap.set(
            "n",
            "<leader>uL",
            ":Diffundo later 1f<cr>",
            {
                desc = "Diffundo later 1f (write)"
            }
        )
        vim.keymap.set(
            "n",
            "<leader>u/",
            ":Diffundo search ",
            {
                desc = "Diffundo search"
            }
        )
        vim.keymap.set(
            "n",
            "<leader>uf",
            ":Diffundo focus<cr>",
            {
                desc = "Diffundo focus"
            }
        )
        vim.keymap.set(
            "n",
            "<leader>uc",
            ":Diffundo close<cr>",
            {
                desc = "Diffundo close"
            }
        )
    end
}
