return {
  "mrcjkb/rustaceanvim",
  version = "^3", -- Recommended
  dependencies = {
    {
      "saecki/crates.nvim",
      version = "stable",
      dependencies = {

        "nvim-lua/plenary.nvim",
      },
    },
  },
  ft = { "rust" },
  config = function()
    vim.g.rustaceanvim = {
      ---@type RustaceanToolsOpts
      tools = {
        -- ...
      },
      ---@type RustaceanLspClientOpts
      server = {
        on_attach = function(client, bufnr)
          -- Set keybindings, etc. here.
        end,
        settings = {
          -- rust-analyzer language server configuration
          ["rust-analyzer"] = {
            checkOnSave = {
              allFeatures = true,
              command = "clippy",
              extraArgs = { "--no-deps" },
            },
          },
        },
        -- ...
      },
      ---@type RustaceanDapOpts
      dap = {},
    }
  end,
}
