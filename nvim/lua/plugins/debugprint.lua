return {
  "andrewferrier/debugprint.nvim",
  config = function()
    local opts = {
      keymaps = {
        normal = {
          plain_below = "<leader>ddp",
          plain_above = "<leader>ddP",
          variable_below = "<leader>ddv",
          variable_above = "<leader>ddV",
          variable_below_alwaysprompt = nil,
          variable_above_alwaysprompt = nil,
          textobj_below = "<leader>ddo",
          textobj_above = "<leader>ddO",
          toggle_comment_debug_prints = nil,
          delete_debug_prints = nil,
        },
        visual = {
          variable_below = "<leader>ddv",
          variable_above = "<leader>ddV",
        },
      },
      commands = {
        toggle_comment_debug_prints = "ToggleCommentDebugPrints",
        delete_debug_prints = "DeleteDebugPrints",
      },
    }
    local wk = require "which-key"
    require("debugprint").setup(opts)
  end,
  dependencies = {
    "echasnovski/mini.nvim", -- Needed to enable :ToggleCommentDebugPrints for NeoVim <= 0.9
    "nvim-treesitter/nvim-treesitter", -- Needed to enable treesitter for NeoVim 0.8
  },
  -- Remove the following line to use development versions,
  -- not just the formal releases
  version = "*",
}
