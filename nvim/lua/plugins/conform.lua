return {
  {
    "stevearc/conform.nvim",
    enabled = false,
    opts = {
      config = {
        lua = {"stylua"},
        python = {"isort", "black", "pylint"},
        javascript = {"prettierd"},
        elixir = {"mix"}
      }
    },
  },
}
