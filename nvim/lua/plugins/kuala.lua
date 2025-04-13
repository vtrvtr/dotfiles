return {
  "mistweaverco/kulala.nvim",
  keys = {
    { "<leader><leader>rs", desc = "Send request" },
    { "<leader><leader>ra", desc = "Send all requests" },
    { "<leader><leader>rb", desc = "Open scratchpad" },
  },
  ft = { "http", "rest" },
  opts = {
    -- your configuration comes here
    global_keymaps = true,
  },
}
