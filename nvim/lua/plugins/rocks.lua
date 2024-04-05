return {
  "rest-nvim/rest.nvim",
  ft = "http",
  version = "*",
  dependencies = { "luarocks.nvim", { "nvim-neotest/nvim-nio" } },
  config = function()
    require("rest-nvim").setup()

    local wk = require "which-key"

    wk.register {
      ["<leader>p"] = {
        r = {
          "<Plug>RestNvim",
          "Rest nvim",
        },
      },
    }
  end,
}
