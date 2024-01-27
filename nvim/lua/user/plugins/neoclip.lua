return {
  "AckslD/nvim-neoclip.lua",
  event = "VeryLazy",
  dependencies = {
    -- you'll need at least one of these
    { "nvim-telescope/telescope.nvim" },
    { "kkharji/sqlite.lua", module = "sqlite" },
  },
  config = function()
    require("neoclip").setup {
      history = 25,
      enable_persistent_history = true,
      continuous_sync = false,
    }
  end,
}
