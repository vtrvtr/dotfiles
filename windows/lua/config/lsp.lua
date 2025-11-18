return {
  "neovim/nvim-lspconfig",
  event = { "BufReadPre", "BufNewFile" },

  config = function()
    local configs = require("lspconfig.configs")

    -- Shared capabilities (extend with cmp later)
    local capabilities = vim.lsp.protocol.make_client_capabilities()

    -- on_attach for LSP-specific keymaps
    local on_attach = function(_, bufnr)
      local map = function(mode, lhs, rhs, desc)
        vim.keymap.set(mode, lhs, rhs, { buffer = bufnr, desc = desc })
      end

      map("n", "gd", vim.lsp.buf.definition, "LSP: go to definition")
      map("n", "gr", vim.lsp.buf.references, "LSP: references")
      map("n", "K",  vim.lsp.buf.hover, "LSP: hover")
      map("n", "<leader>rn", vim.lsp.buf.rename, "LSP: rename")
      map("n", "<leader>ca", vim.lsp.buf.code_action, "LSP: code action")
      map("n", "<leader>f", function()
        vim.lsp.buf.format({ async = true })
      end, "LSP: format")
    end

    ----------------------------------------------------------------------
    -- Helper: register servers using the NEW API
    ----------------------------------------------------------------------
    local function setup(server, opts)
      -- 1. Build modern LSP config
      local config = vim.lsp.config.create(vim.tbl_deep_extend("force", {
        capabilities = capabilities,
        on_attach   = on_attach,
      }, opts or {}))

      -- 2. Register in lspconfig’s registry (replaces lspconfig.SERVER.setup)
      if not configs[server] then
        configs[server] = { default_config = config }
      end
    end

    ----------------------------------------------------------------------
    -- Servers (using new API)
    ----------------------------------------------------------------------

    -- Lua
    setup("lua_ls", {
      cmd = { "lua-language-server" },
      settings = {
        Lua = {
          diagnostics = { globals = { "vim" } },
        },
      },
    })

    -- Python
    setup("pyright", {
      cmd = { "pyright-langserver", "--stdio" },
    })

    -- TypeScript / JavaScript
    setup("ts_ls", {
      cmd = { "typescript-language-server", "--stdio" },
    })
  end,
}

