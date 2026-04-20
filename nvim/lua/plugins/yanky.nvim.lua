-- Plugin: gbprod/yanky.nvim
-- Installed via store.nvim

return {
  "gbprod/yanky.nvim",
  config = function()
    require("yanky").setup {}
    local ok, wk = pcall(require, "which-key")
    if ok then
      wk.add {
        {
          "<leader>fy",
          "<cmd>YankyRingHistory<cr>",
          desc = "Find yank history",
        },
      }
    end
  end,
}
