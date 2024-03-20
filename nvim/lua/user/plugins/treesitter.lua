return {
  "nvim-treesitter/nvim-treesitter",
  commit = "03f650705c0c10f97b214ca4ecca3c25ff9bee7d",
  opts = function(_, opts)
    -- add more things to the ensure_installed table protecting against community packs modifying it
    opts.ensure_installed = require("astronvim.utils").list_insert_unique(opts.ensure_installed, {
      "lua",
      "elixir",
      "heex",
      "latex",
      "html",
      "xml",
      "http",
      "json",
      "graphql",
    })
  end,
}
