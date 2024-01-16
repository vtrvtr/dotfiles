return {
  "AckslD/nvim-neoclip.lua",
  event = "VeryLazy",
  dependencies = {
    -- you'll need at least one of these
    { "nvim-telescope/telescope.nvim" },
    { "kkharji/sqlite.lua",           module = "sqlite" },
    -- {'ibhagwan/fzf-lua'},
  },
  config = function()
    require("neoclip").setup {
      enable_persistent_history = true,
      continuous_sync = true,
    }
  end,
}
