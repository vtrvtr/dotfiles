-- lol
return {
  "MagicDuck/grug-far.nvim",
  config = function()
    require("grug-far").setup {
      keymaps = {
        replace = "<enter><enter>",
        qflist = "<C-q>",
        gotoLocation = "<enter>",
        close = "<C-x>",
      },
    }
    vim.cmd "cnoreabbrev Replace GrugFar"
    vim.cmd "cnoreabbrev R GrugFar"
  end,
}
