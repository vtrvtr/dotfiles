return {
  "akinsho/toggleterm.nvim",
  event = "BufEnter",
  name = "toggleterm",
  opts = function(_, config)
    -- config variable is the default configuration table for the setup function call
    -- local null_ls = require "null-ls"

    -- Check supported formatters and linters
    -- https://github.com/jose-elias-alvarez/null-ls.nvim/tree/main/lua/null-ls/builtins/formatting
    -- https://github.com/jose-elias-alvarez/null-ls.nvim/tree/main/lua/null-ls/builtins/diagnostics
    config.open_mapping = [[<c-t>]]
    config.direction = "float"
    config.sources = {
      -- Set a formatter
      -- null_ls.builtins.formatting.stylua,
      -- null_ls.builtins.formatting.prettier,
    }
    config.shell = function()
      if string.find(vim.loop.os_uname().sysname, "Win") then
        return "powershell.exe"
      else
        return vim.o.shell
      end
    end

    -- Toggle normal mode
    vim.api.nvim_set_keymap("t", "<Esc>", "<C-\\><C-n>", { noremap = true, silent = true })
    return config -- return final config table
  end,
}
