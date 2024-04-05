return {
  "cbochs/portal.nvim",
  event = "BufEnter",
  opts = function(_, config)
    local width = vim.api.nvim_get_option "columns"
    local height = vim.api.nvim_get_option "lines"

    config.window_options = {
      relative = "editor",
      width = 80,
      height = 5,
      row = math.ceil(height / 2),
      col = math.ceil(width / 2) - 40,
      focusable = false,
      border = "rounded",
      noautocmd = true,
    }
    config.labels = {
      "j",
      "k",
      "h",
      "l",
      "q",
      "w",
      "e",
      "r",
      "z",
      "x",
      "c",
      "v",
    }
    return config -- return final config table
  end,
}
