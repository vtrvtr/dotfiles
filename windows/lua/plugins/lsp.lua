return {
  "neovim/nvim-lspconfig",
  event = { "BufReadPre", "BufNewFile" },
  config = function()
    local configs = require("lspconfig.configs")
    local ok_util, util = pcall(require, "lspconfig.util")
    if not ok_util then return end

    -- register server configs without triggering the deprecated require('lspconfig') path
    local function ensure_config(name)
      if configs[name] then return true end
      local ok, def = pcall(require, "lspconfig.configs." .. name)
      if not ok then return false end
      configs[name] = def
      return true
    end

    -- nvim-cmp / completion capabilities (safe even if you don't use cmp)
    local capabilities = vim.lsp.protocol.make_client_capabilities()
    local ok_cmp, cmp_lsp = pcall(require, "cmp_nvim_lsp")
    if ok_cmp then
      capabilities = cmp_lsp.default_capabilities(capabilities)
    end

    -- on_attach: keymaps only when LSP is active
    local on_attach = function(_, bufnr)
      local map = function(mode, lhs, rhs, desc)
        vim.keymap.set(mode, lhs, rhs, { buffer = bufnr, desc = desc })
      end

      map("n", "gd", vim.lsp.buf.definition, "Goto definition")
      map("n", "gD", vim.lsp.buf.declaration, "Goto declaration")
      map("n", "gr", vim.lsp.buf.references, "References")
      map("n", "gi", vim.lsp.buf.implementation, "Goto implementation")

      map("n", "K", vim.lsp.buf.hover, "Hover")
      map("n", "<leader>rn", vim.lsp.buf.rename, "Rename symbol")
      map("n", "<leader>ca", vim.lsp.buf.code_action, "Code action")

      map("n", "<leader>lf", function() vim.lsp.buf.format { async = true } end, "Format buffer")

      map("n", "[d", vim.diagnostic.goto_prev, "Prev diagnostic")
      map("n", "]d", vim.diagnostic.goto_next, "Next diagnostic")
      map("n", "<leader>ld", vim.diagnostic.open_float, "Line diagnostics")
    end

    -- Lua: lua_ls
    if ensure_config("lua_ls") then
      configs.lua_ls.setup {
        on_attach = on_attach,
        capabilities = capabilities,
        settings = {
          Lua = {
            diagnostics = { globals = { "vim" } },
            workspace = { checkThirdParty = false },
          },
        },
      }
    end

    -- Python: pyright
    if ensure_config("pyright") then
      configs.pyright.setup {
        on_attach = on_attach,
        capabilities = capabilities,
      }
    end

    -- add more servers here as you go
  end,
}

