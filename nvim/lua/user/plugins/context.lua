
return {
  "nvim-treesitter/nvim-treesitter-context",
  event = "BufEnter",
  opts = function (_, opts)
    opts.line_number = true
    return opts
  end
}
