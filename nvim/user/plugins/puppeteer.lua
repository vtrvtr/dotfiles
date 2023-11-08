return {
  'chrisgrieser/nvim-puppeteer',
  dependencies = "nvim-treesitter/nvim-treesitter",
  opts = function(_, config)
    return config -- return final config table
  end,
}
