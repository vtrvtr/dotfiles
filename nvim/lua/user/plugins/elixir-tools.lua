return {
  "elixir-tools/elixir-tools.nvim",
  version = "*",
  event = { "BufReadPre", "BufNewFile" },
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
          local wk = require "which-key"
          wk.register {
            ["<leader>l"] = {
              f = {
                function() vim.lsp.buf.format() end,
                "Format buffer Elixir",
              },
              R = {
                function()
                  require("telescope.builtin").lsp_references()
                end,
                "Find all references Elixir",
              },
            },
            ["g"] = {
              d = {
                function() vim.lsp.buf.definition() end,
                "Go to definition Elixir",
              },
            },
          }
        end,
      },
    }
  end,
  dependencies = {
    "nvim-lua/plenary.nvim",
  },
}
