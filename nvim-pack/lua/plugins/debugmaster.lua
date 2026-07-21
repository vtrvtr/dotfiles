return {
  { "rcarriga/nvim-dap-ui", enabled = false },
  {
    "miroshQa/debugmaster.nvim",
    -- mason-nvim-dap owns the lldb adapter + on_config listeners (Rust
    -- formatters, preLaunchTask). Depending on nvim-dap alone starts a session
    -- without them, so pull in that spec too.
    dependencies = {
      "mfussenegger/nvim-dap",
      "jay-babu/mason-nvim-dap.nvim",
      "jbyuki/one-small-step-for-vimkind",
    },
    keys = {
      { "<leader>ds", desc = "Toggle debug mode", mode = { "n", "v" } },
    },
    config = function()
      local dm = require("debugmaster")
      vim.keymap.set({ "n", "v" }, "<leader>ds", dm.mode.toggle, { nowait = true })
      vim.keymap.set("n", "<Esc>", dm.mode.disable)
      vim.keymap.set("t", "<C-\\>", "<C-\\><C-n>", { desc = "Exit terminal mode" })

      dm.plugins.osv_integration.enabled = true
    end,
  },
}
