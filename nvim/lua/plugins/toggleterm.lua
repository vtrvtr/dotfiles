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

    function SetCwdToTerminalCwd()
      -- Get the current buffer number and check if it's a terminal buffer
      local term_bufnr = vim.api.nvim_get_current_buf()
      local term_chan_id = vim.b.terminal_job_id
      if not term_chan_id then
        print "Not in a terminal buffer"
        return
      end

      -- Run a command in the terminal to print its current working directory
      vim.fn.chansend(term_chan_id, "pwd\n")

      -- Wait for a short duration to allow the command to execute
      vim.defer_fn(function()
        -- Read the output from the terminal buffer
        local lines = vim.api.nvim_buf_get_lines(term_bufnr, 0, -1, false)
        local cwd = nil

        -- Find the cwd in the lines (assuming it will be in the last line)
        for _, line in ipairs(lines) do
          if line:match "^/" then cwd = line end
        end

        if not cwd or #cwd == 0 then
          print "Failed to get cwd"
          return
        end

        -- Set Neovim's cwd to the terminal's cwd
        vim.cmd("cd " .. cwd)
      end, 100) -- 100ms delay
    end

    -- Function to set Neovim's cwd to the terminal's cwd

    local wk = require "which-key"

    wk.add {
      { "<leader>tc", SetCwdToTerminalCwd, desc = "Set cwd", mode = "n" },
    }

    return config -- return final config table
  end,
}
