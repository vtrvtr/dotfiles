
return {
  "andrewferrier/debugprint.nvim",
  keys = {
    { "<leader>ddp", desc = "Debug print below" },
    { "<leader>ddP", desc = "Debug print above" },
    { "<leader>ddv", mode = { "n", "x" }, desc = "Debug variable below" },
    { "<leader>ddV", mode = { "n", "x" }, desc = "Debug variable above" },
    { "<leader>ddo", desc = "Debug textobj below" },
    { "<leader>ddO", desc = "Debug textobj above" },
  },
  cmd = { "ToggleCommentDebugPrints", "DeleteDebugPrints" },
  dependencies = {
    "echasnovski/mini.nvim",
    "nvim-treesitter/nvim-treesitter",
  },
  sem_version = "*",
  config = function()
    require("debugprint").setup {
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
  end,
}
