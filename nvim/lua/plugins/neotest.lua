return {
  "nvim-neotest/neotest",
  lazy = true,
  event = "VeryLazy",
  dependencies = {
    "nvim-neotest/nvim-nio",
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
    wk.add {
      { "<leader>te", group = "Test" },
      {
        "<leader>ted",
        function() require("neotest").run.run { strategy = "dap" } end,
        desc = "Test Debug",
      },
      {
        "<leader>ter",
        function() require("neotest").run.run(vim.fn.expand "%") end,
        desc = "Run all tests.",
      },
      {
        "<leader>te<space>",
        function() require("neotest").run.run() end,
        desc = "Run test under cursor.",
      },
      {
        "<leader>tef",
        function() require("neotest").run.run_last() end,
        desc = "Run last test.",
      },
      {
        "<leader>tes",
        function() require("neotest").summary.toggle() end,
        desc = "Test summary",
      },
      {
        "<leader>teo",

        function() require("neotest").output_panel.toggle() end,
        desc = "Test output",
      },
    }
  end,
}
