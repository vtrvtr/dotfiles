
return {
  "nvim-treesitter/nvim-treesitter-context",
  event = "BufEnter",
  enabled=false,
  opts = function (_, opts)
    opts.line_number = true
    return opts
  end
}
