return {
  "karb94/neoscroll.nvim",
  enabled = false,
  event = "VeryLazy",
  config = function()
    require("neoscroll").setup {
      respect_scrolloff = true,
    }

    local neoscroll = require "neoscroll"
    -- Syntax: t[keys] = {function, {function arguments}}
    -- Use the "sine" easing function
    -- V
    local keymap = {
      ["<C-u>"] = function() neoscroll.ctrl_u { duration = 250, easing = "quadradic" } end,
      ["<C-k>"] = function() neoscroll.ctrl_u { duration = 150, easing = "quadradic" } end,
      ["<C-d>"] = function() neoscroll.ctrl_d { duration = 250, easing = "quadradic" } end,
      ["<C-j>"] = function() neoscroll.ctrl_d { duration = 150, easing = "quadradic" } end,
      ["<C-b>"] = function() neoscroll.ctrl_b { duration = 450, easing = "quadradic" } end,
      ["<C-f>"] = function() neoscroll.ctrl_f { duration = 450, easing = "quadradic" } end,
      ["<C-y>"] = function() neoscroll.scroll(-0.1, { move_cursor = false, duration = 100, easing = "quadradic" }) end,
      ["<C-e>"] = function() neoscroll.scroll(0.1, { move_cursor = false, duration = 100, easing = "quadradic" }) end,
      ["zt"] = function() neoscroll.zt { half_win_duration = 250, easing = "quadradic" } end,
      ["zz"] = function() neoscroll.zz { half_win_duration = 250, easing = "quadradic" } end,
      ["zb"] = function() neoscroll.zb { half_win_duration = 250, easing = "quadradic" } end,
    }
    local modes = { "n", "v", "x" }
    for key, func in pairs(keymap) do
      vim.keymap.set(modes, key, func)
    end
  end,
}
