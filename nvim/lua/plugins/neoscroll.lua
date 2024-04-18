return {
  "karb94/neoscroll.nvim",
  -- enabled = false,
  event = "VeryLazy",
  config = function()
    require("neoscroll").setup {
      respect_scrolloff = true,
    }
    local t = {}
    -- Syntax: t[keys] = {function, {function arguments}}
    -- Use the "sine" easing function
    t["<C-k>"] = { "scroll", { "-vim.wo.scroll", "true", "350", [['quadratic']] } }
    t["<C-j>"] = { "scroll", { "vim.wo.scroll", "true", "350", [['quadratic']] } }
    require("neoscroll.config").set_mappings(t)
  end,
}
