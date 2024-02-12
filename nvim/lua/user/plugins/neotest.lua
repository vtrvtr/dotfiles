return {
  "nvim-neotest/neotest",
  lazy = true,
  event = "VeryLazy",
  dependencies = {
    "nvim-lua/plenary.nvim",
    "jfpedroza/neotest-elixir",
    "nvim-neotest/neotest-python",
    "rouge8/neotest-rust",
    "antoinemadec/FixCursorHold.nvim",
    "nvim-treesitter/nvim-treesitter",
  },
  config = function()
    require("neotest").setup {
      adapters = {
        require "neotest-python",
        require "neotest-elixir",
        require "neotest-rust",
      },
    }
    local wk = require "which-key"
    wk.register({
      t = {
        e = {
          d = {
            function() require("neotest").run.run { strategy = "dap" } end,
            "Test Debug",
          },
        },
      },
    }, { prefix = "<leader>" })
  end,
}
