return {
  "elixir-tools/elixir-tools.nvim",
  version = "*",
  ft = { "ex", "exs", "heex", "elixir" },
  config = function()
    local elixir = require "elixir"
    local elixirls = require "elixir.elixirls"

    elixir.setup {
      nextls = { enable = true },
      credo = { enable = true },
      elixirls = {
        enable = true,
        tag = "v0.18.0",
        settings = elixirls.settings {
          dialyzerEnabled = false,
          enableTestLenses = true,
        },
        on_attach = function(client, bufnr)
          vim.keymap.set("n", "<space>fp", ":ElixirFromPipe<cr>", { buffer = true, noremap = true })
          vim.keymap.set("n", "<space>tp", ":ElixirToPipe<cr>", { buffer = true, noremap = true })
          vim.keymap.set("v", "<space>em", ":ElixirExpandMacro<cr>", { buffer = true, noremap = true })
        end,
      },
    }
  end,
  dependencies = {
    "nvim-lua/plenary.nvim",
  },
}
