return {
  "chrisgrieser/nvim-origami",
  enabled = true,
  event = "BufReadPost", -- later or on keypress would prevent saving folds
  opts = true, -- needed even when using default config
}
