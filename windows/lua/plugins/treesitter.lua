return {
  "nvim-treesitter/nvim-treesitter",
  build = ":TSUpdate",
  lazy = false,
  opts = function(_, opts)
    opts.ensure_installed = opts.ensure_installed or {}
    for _, lang in ipairs { "lua", "elixir", "heex", "latex", "html", "xml", "http", "json", "graphql" } do
      if not vim.tbl_contains(opts.ensure_installed, lang) then table.insert(opts.ensure_installed, lang) end
    end
    opts.highlight = opts.highlight or { enable = true }
    return opts
  end,
}

