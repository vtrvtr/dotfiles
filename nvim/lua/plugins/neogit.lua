return {
  "NeogitOrg/neogit",
  lazy = true,
  dependencies = {
    "nvim-lua/plenary.nvim", -- required
    "nvim-telescope/telescope.nvim", -- optional
    "sindrets/diffview.nvim", -- optional
    "ibhagwan/fzf-lua", -- optional
  },
  branch = "master",
  -- config = true,
  opts = function(opts)
    local wk = require "which-key"
    wk.add {
      {
        "<Leader>gg",
        function() require("neogit").open { kind = "split_above" } end,
        desc = "Open neogit",
      },
    }
  end,
}
