
return {
  "nvimtools/none-ls.nvim",
  main = "null-ls",
  event = "VeryLazy",
  opts = function(_, config)
    config.sources = config.sources or {
      -- add builtins here, e.g. require("null-ls").builtins.formatting.stylua,
    }
    return config
  end,
}
