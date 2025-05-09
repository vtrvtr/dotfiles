return {
  "olimorris/codecompanion.nvim",
  opts = {
    strategies = {
      chat = {
        adapter = "copilot",
      },
      inline = {
        adapter = "copilot",
      },
    },
    show_defaults = false,
    adapters = {
      copilot = function()
        local adapters = require "codecompanion.adapters"
        return adapters.extend("copilot", {
          schema = {
            model = {
              default = "o4-mini",
            },
          },
        })
      end,
    },
  },
  dependencies = {
    "nvim-lua/plenary.nvim",
    "nvim-treesitter/nvim-treesitter",
    {
      "zbirenbaum/copilot.lua",
      cmd = "Copilot",
      build = ":Copilot auth",
      event = "BufReadPost",
      dependencies = {},
      opts = function(opts)
        opts = {
          suggestion = { enabled = false },
          panel = { enabled = false },
          filetypes = {
            markdown = true,
            help = true,
          },
        }
        local wk = require "which-key"
        wk.add {
          mode = { "n" },
          { "<leader>aa", "<cmd>CodeCompanionChat Toggle<CR>" },
          desc = "Code companion Chat",
        }
        wk.add {
          mode = { "n" },
          { "<leader>ac", "<cmd>CodeCompanionActions<CR>" },
          desc = "Code Companion actions",
        }
        return opts
      end,
    },
  },
}
