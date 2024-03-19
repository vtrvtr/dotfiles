return {
  "rest-nvim/rest.nvim",
  ft = "http",
  version = "1.2.1",
  dependencies = { "luarocks.nvim" },
  config = function()
    require("rest-nvim").setup()

    local wk = require "which-key"

    wk.register {
      p = {
        r = {
          "<Plug>RestNvim",
          "Rest nvim",
        },
      },
    }
  end,
}
