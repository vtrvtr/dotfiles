return {
  "jbyuki/instant.nvim",
  name = "instant",
  cmd = {"InstantLoad"},
  config = function(_, config)
    -- config variable is the default configuration table for the setup function call
    -- local null_ls = require "null-ls"

    -- Check supported formatters and linters
    -- https://github.com/jose-elias-alvarez/null-ls.nvim/tree/main/lua/null-ls/builtins/formatting
    -- https://github.com/jose-elias-alvarez/null-ls.nvim/tree/main/lua/null-ls/builtins/diagnostics
    config.instant_username = "Vitor";
    return config -- return final config table

  end,
  enabled = true
}
