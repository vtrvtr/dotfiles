return {
  "jiaoshijie/undotree",
  dependencies = "nvim-lua/plenary.nvim",
  opts = {
    window = {
      win_blend = 80,
    },
  },
  keys = { -- load the plugin only when using it's keybinding:
    { "<leader>fu", "<cmd>lua require('undotree').toggle()<cr>", "Undo" },
  },
}
