return {
  "mrjones2014/smart-splits.nvim",
  dependencies = {
    {
      "debugloop/layers.nvim",
      opts = {},
    },
  },
  opts = {},
  config = function(_, opts)
    local wk = require "which-key"
    require("layers").setup {}
    WINDOWS_MODE = Layers.mode.new "Window Control"
    WINDOWS_MODE:auto_show_help()
    wk.add {
      { "<leader>w", function() WINDOWS_MODE:activate() end },
      desc = "Window mode",
    }

    local increase_w = function(amount)
      local cur_win = vim.api.nvim_get_current_win()
      local new_win = vim.api.nvim_get_current_win()
      local current_width = vim.api.nvim_win_get_width(new_win)
      vim.api.nvim_win_set_width(new_win, current_width + amount)
      vim.api.nvim_set_current_win(cur_win)
    end
    local increase_h = function(amount)
      local cur_win = vim.api.nvim_get_current_win()
      local new_win = vim.api.nvim_get_current_win()
      local current_width = vim.api.nvim_win_get_height(new_win)
      vim.api.nvim_win_set_height(new_win, current_width + amount)
      vim.api.nvim_set_current_win(cur_win)
    end
    WINDOWS_MODE:keymaps {
      n = {
        {
          "j",
          function() increase_h(-5) end,
          { desc = "Increase up" },
        },
        {
          "k",
          function() increase_h(5) end,
          { desc = "Increase down" },
        },
        {
          "h",
          function() increase_w(5) end,
          { desc = "Increase left" },
        },
        {
          "l",
          function() increase_w(-5) end,
          { desc = "Increase right" },
        },
        {
          "s",
          function() vim.cmd "split" end,
          { desc = "Horizontal split" },
        },
        {
          "v",
          function() vim.cmd "vsplit" end,
          { desc = "Vertical split" },
        },
        {
          "<Esc>",
          function() WINDOWS_MODE:deactivate() end,
          { desc = "Quit" },
        },
        {
          "<Enter>",
          function() WINDOWS_MODE:deactivate() end,
          { desc = "Quit" },
        },
      },
    }
  end,
}
