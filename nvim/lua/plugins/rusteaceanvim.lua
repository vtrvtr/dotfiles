return {
  "mrcjkb/rustaceanvim",
  dependencies = {
    {
      "saecki/crates.nvim",
      tag = "stable",
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
          --
          vim.lsp.inlay_hint.enable()
        end,
        settings = {
          -- rust-analyzer language server configuration
          ["rust-analyzer"] = {
            checkOnSave = {
              allFeatures = true,
              command = "clippy",
              extraArgs = { "--no-deps" },
            },
            diagnostics = {
              enableExperimental = true,
              disabled = { "unresolved-proc-macro" },
            },
            cargo = {
              features = "all",
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
