-- Plugin: lewis6991/gitsigns.nvim
-- Installed via store.nvim

return {
  "lewis6991/gitsigns.nvim",
  event = "VeryLazy",
  keys = {
    {
      "]g",
      function()
        require("gitsigns").next_hunk()
      end,
      desc = "Next git change",
    },
    {
      "[g",
      function()
        require("gitsigns").prev_hunk()
      end,
      desc = "Previous git change",
    },
  },
}