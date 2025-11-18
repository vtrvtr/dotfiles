return {
  "AbysmalBiscuit/insert-inlay-hints.nvim",
  keys = {
    {
      "<leader>ic",
      function()
        require("insert-inlay-hints").closest()
      end,
      desc = "Insert the colsest inline hint as code.",
    },
    {
      "<leader>il",
      function()
        require("insert-inlay-hints").line()
      end,
      desc = "Insert all inline hints on current line as code.",
    },
    {
      "<leader>i",
      function()
        require("insert-inlay-hints").visual()
      end,
      desc = "Insert all inlay hints in the current visual selection as code.",
      mode = { "v" },
    },
    {
      "<leader>ia",
      function()
        return require("insert-inlay-hints").all()
      end,
      desc = "Insert all inlay hints in the current buffer as code.",
    },
  },
}
