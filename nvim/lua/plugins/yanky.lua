return {
  "gbprod/yanky.nvim",

  -- opts = {
  --   -- your configuration comes here
  --   -- or leave it empty to use the default settings
  --   -- refer to the configuration section below
  -- },
  config = function()
    require("yanky").setup {}
    local wk = require "which-key"
    wk.add {
      {
        "<leader>fy",
        "<cmd>YankyRingHistory<cr>",
        desc = "Find yank history",
      },
    }
  end,
}
