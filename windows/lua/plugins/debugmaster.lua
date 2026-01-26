return {
  { "rcarriga/nvim-dap-ui", enabled = false },
  {
    "miroshQa/debugmaster.nvim",
    dependencies = { "mfussenegger/nvim-dap", "jbyuki/one-small-step-for-vimkind" },
    config = function()
      local dm = require("debugmaster")
      vim.keymap.set({ "n", "v" }, "<leader>ds", dm.mode.toggle, { nowait = true })
      vim.keymap.set("n", "<Esc>", dm.mode.disable)
      vim.keymap.set("t", "<C-\\>", "<C-\\><C-n>", { desc = "Exit terminal mode" })

      dm.plugins.osv_integration.enabled = true
    end,
  },
}
